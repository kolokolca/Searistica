using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using DataAccess;
using ServiceContracts;
using Problem = ServiceContracts.Problem;

namespace Business
{
    public class ByteKnightLogic
    {
        public Response<ScoreBoardData> GetSoreBoardData()
        {
            Thread.Sleep(200);
            var response = new Response<ScoreBoardData> {Data = new ScoreBoardData()};
            try
            {
                using (var work = new UnitOfWork())
                {
                    var teamRepository = RepositoryContainer.GetRepository<Team>(work);
                    var eligibleTeams = teamRepository.Filter(t => t.Score > 0).OrderByDescending(t => t.Score);
                    var distinctScores = eligibleTeams.Select(t => t.Score).Distinct().OrderByDescending(s => s);
                    var submittedProblemsRepository = RepositoryContainer.GetRepository<SubmittedProblem>(work);

                    var position = 0;
                    foreach (var score in distinctScores)
                    {
                        var sameSocredTeams = eligibleTeams.Where(t => t.Score == score);
                        var sameSocredTeamIds = sameSocredTeams.Select(t => t.Id);


                        var lastSubmitionByTeams = new List<SubmittedProblem>();
                        foreach (var teamId in sameSocredTeamIds)
                        {
                            var submittedProblems = submittedProblemsRepository.Filter(sp => sp.TeamId == teamId);
                            var lastSubmittedProblem = submittedProblems.OrderBy(sp => sp.Time).ToList().Last();
                            lastSubmitionByTeams.Add(lastSubmittedProblem);
                        }
                        lastSubmitionByTeams = lastSubmitionByTeams.OrderBy(lsp => lsp.Time).ToList();

                        foreach (var lastSubmitionByATeam in lastSubmitionByTeams)
                        {
                            var teamScore = new TeamScore
                                                {
                                                    Name = lastSubmitionByATeam.Team.Name,
                                                    Score = lastSubmitionByATeam.Team.Score,
                                                    Position = ++position,
                                                    Id = lastSubmitionByATeam.Team.Id
                                                };
                            var submittedProblems =
                                submittedProblemsRepository.Filter(sp => sp.TeamId == teamScore.Id).OrderBy(
                                    sp => sp.Time);
                            foreach (var submittedProblem in submittedProblems)
                            {
                                var solvedProblem = new SolvedProblem
                                                        {
                                                            Name = submittedProblem.Problem.Name,
                                                            Time =
                                                                submittedProblem.Time.ToString(
                                                                    "MM/dd/yyyy h:mm:ss.ffffff tt")
                                                        };
                                teamScore.SolvedProblems.Add(solvedProblem);
                            }
                            response.Data.TeamsOrderByScore.Add(teamScore);

                        }

                    }

                }

            }
            catch (Exception)
            {
                response.Success = false;
                response.ErrorMessage = "Failed";
                return response;
            }
            return response;
        }

        public Response<UnSolved> GetUnsolavedProblem(int teamId)
        {
            Thread.Sleep(200);
            var response = new Response<UnSolved>() {Data = new UnSolved()};
            try
            {
                using (var work = new UnitOfWork())
                {
                    var problemRepository = RepositoryContainer.GetRepository<DataAccess.Problem>(work);
                    var allProblems = problemRepository.All();
                    var allProblemIds = allProblems.Select(p => p.Id);

                    var submittedProblemsRepository = RepositoryContainer.GetRepository<SubmittedProblem>(work);
                    var submittedProblems = submittedProblemsRepository.Filter(s => s.TeamId == teamId);
                    var submittedProblemIds = new List<int>();
                    if (submittedProblems != null)
                        submittedProblemIds = submittedProblems.Select(s => s.ProblemId).ToList();
                    var unslovedProblemIds = allProblemIds.Where(id => submittedProblemIds.Contains(id) == false);
                    var unslovedProblems = allProblems.Where(p => unslovedProblemIds.Contains(p.Id));

                    foreach (var unslovedProblem in unslovedProblems)
                    {
                        var problem = new Problem
                                          {
                                              Name = unslovedProblem.Name,
                                              Id = unslovedProblem.Id,
                                              Point = unslovedProblem.Point
                                          };
                        response.Data.Problems.Add(problem);
                        response.Success = true;

                    }
                    return response;
                }

            }
            catch (Exception)
            {
                return new Response<UnSolved>() {Success = false, ErrorMessage = "Failed"};
            }
        }

        public Response<string> SubmitProblem(string problemIdAsString, string key, int teamId)
        {
            var response = new Response<string>();
            try
            {
                using (var work = new UnitOfWork())
                {
                    var submittedProblemsRepository = RepositoryContainer.GetRepository<SubmittedProblem>(work);
                    var teamRepository = RepositoryContainer.GetRepository<Team>(work);

                    int problemId;
                    int.TryParse(problemIdAsString.Trim(), out problemId);

                    if (problemId > 0 && IsAlreadySubmitted(submittedProblemsRepository, teamId, problemId) == false)
                    {
                        var problemRepository = RepositoryContainer.GetRepository<DataAccess.Problem>(work);
                        var problem = problemRepository.Filter(p => p.Id == problemId).FirstOrDefault();

                        var solutionRepository = RepositoryContainer.GetRepository<TeamProblemSolutionKey>(work);
                        var dbSolution =
                            solutionRepository.Filter(s => s.TeamId == teamId && s.ProblemId == problemId).
                                FirstOrDefault();

                        if (dbSolution != null)
                        {
                            if (problem != null && dbSolution.SolutionKey == key.Trim())
                            {
                                var submittedProblem = new SubmittedProblem {ProblemId = problemId, TeamId = teamId};
                                var dateTimeWithFormat = DateTime.Now.ToString("MM/dd/yyyy h:mm:ss.ffffff tt H");
                                submittedProblem.Time = DateTime.Parse(dateTimeWithFormat);
                                submittedProblemsRepository.Add(submittedProblem);

                                var team = teamRepository.Filter(t => t.Id == teamId).First();
                                team.Score += problem.Point;
                                teamRepository.Update(team);

                                work.SaveChanges();

                                response.Success = true;
                                return response;
                            }

                            response.Success = false;
                            response.ErrorMessage = "Key doesn't match";
                            return response;
                        }

                        response.Success = false;
                        response.ErrorMessage = "Your team hasn't been assigned to a solution key";
                    }
                    return response;

                }
            }
            catch (Exception)
            {
                response.Success = false;
                response.ErrorMessage = "Submission failed";
                return response;
            }
        }

        private bool IsAlreadySubmitted(IRepository<SubmittedProblem> submittedProblemsRepository, int teamId,int problemId)
        {
            var problem =
                submittedProblemsRepository.Filter(sp => sp.TeamId == teamId && sp.ProblemId == problemId).
                    FirstOrDefault();
            return problem != null;
        }

        public bool IsAuthenticate(string teamName, ref int teamId)
        {
            using (var work = new UnitOfWork())
            {
                var teamRepository = RepositoryContainer.GetRepository<Team>(work);
                var team = teamRepository.Find(u => u.Name.ToLower() == teamName.Trim().ToLower());
                if (team != null)
                {
                    teamId = team.Id;
                    return true;
                }
                return false;
            }
        }

        public Response<string> GetTeamName(int teamId)
        {
            var response = new Response<string>();
            try
            {
                using (var work = new UnitOfWork())
                {
                    var teamRepository = RepositoryContainer.GetRepository<Team>(work);
                    var team = teamRepository.Filter(t => t.Id == teamId).First();
                    response.Data = team.Name;
                    return response;
                }

            }
            catch (Exception)
            {
                response.Success = false;
                response.ErrorMessage = "failed";
                return response;
            }

        }
    }
}
