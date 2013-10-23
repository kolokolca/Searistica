var _submitScoreTab = null;
var _scorBoardTab = null;

$(function () {
    $(".tabHeader ul li a").click(function () {
        $("*").removeClass("active");
        var link = $(this);
        link.addClass("active");
        if (link.attr("id") == "submitProblem") {
            if (_submitScoreTab == null)
                _submitScoreTab = new SubmitScoreTab();

            _scorBoardTab.clearTimer();
            _submitScoreTab.loadUnSolvedProbelms();
        }
        if (link.attr("id") == "scoreBoard") {
            if (_scorBoardTab == null)
                _scorBoardTab = new ScoreBoardTab();
            _scorBoardTab.show();
        }
    });
    
    getDataFromService("GetTeamName ", null, function (response) {
        $("#teamName").html(response.Data);
        if (_scorBoardTab == null) {
            _scorBoardTab = new ScoreBoardTab();
            _scorBoardTab.show();
        }
    });
});

var ScoreBoardTab = function () {
    var tab = {
        clearIntervalId: null,
        getHmlTemplate: function () {
            var markup = ["{{each Data.TeamsOrderByScore}}",
                            '<tr class="row">',
                                '<td class="rank">',
                                    '${Position}.',
                                '</td>',
                                '<td class="team">',
                                    '${Name}',
                                '</td>',
                                '<td>',
                                    '{{html $item.getSolvedProblems(SolvedProblems) }}',
                                '</td>',
                                '<td class="score">',
                                    '${Score}',
                                '</td>',
                            '</tr>',
                          "{{/each}}"];
            var templateHtml = markup.join('');
            var table = ['<table>',
                            '<th class="tableHeader">',
                                'Rank',
                            '</th>',
                            '<th class="tableHeader">',
                                'Team',
                            '</th>',
                            '<th class="tableHeader">',
                                'Submitted Problems',
                            '</th>',
                            '<th>',
                                'Score',
                            '</th>',
                                templateHtml,
                         '</table>'];

            return table.join('');
        },
        clearElements: function () {
            var mainContainer = $("#divDynamicContents");
            mainContainer.children().hide();
            var scoreBoardTable = $("#scoreBoardContent");
            scoreBoardTable.empty();
        },
        setTimer: function () {
            if (tab.clearIntervalId == null)
                tab.clearIntervalId = window.setInterval(function () {
                    tab.show();
                }, 1000 * 5);
        },
        clearTimer: function () {
            if (tab.clearIntervalId) {
                window.clearInterval(tab.clearIntervalId);
                tab.clearIntervalId = null;
            }
        },
        show: function () {
            var scope = this;
            var tabContent = $("#scoreBoardTabContent");
            tabContent.showLoading();

            getDataFromService("GetSoreBoardData", null, function (response) {
                $.template("soreBoardTemplate", tab.getHmlTemplate());
                var html = $.tmpl("soreBoardTemplate", response, {
                    getSolvedProblems: function (solvedProblems) {
                        var htm = '';
                        $(solvedProblems).each(function (index, solvedProblem) {
                            htm += solvedProblem.Name + " @ " + solvedProblem.Time + " <br/>";
                        });
                        return htm;
                    }
                }).html();
                if (response.Data.TeamsOrderByScore.length == 0)
                    html = "<span class='nodata'> No submittion yet !!!</span>";
                
                tab.clearElements();
                tabContent.hideLoading();
                var scoreBoardTable = $("#scoreBoardContent");
                scoreBoardTable.html(html);
                tabContent.show();
                tab.setTimer();
            }, scope, false);
        }
    };
    return tab;
};

var SubmitScoreTab = function () {
//     '<input type="text" id="problemKey_${Id}"></input>',
    var tab = {
        getHmlTemplate: function () {
            var markup = ["{{each Data.Problems}}",
                            '<tr class="row" id="problem_${Id}">',
                                '<td>',
                                    '<div class="unsolvedProblemElement problemName" title="${Name}">${Name},&nbsp; <span class="point"> Point (${Point}) </span></div>',
                                '</td>',
                                '<td>',
                                    '<div class="key">Key:</div>',
                                '</td>',
                                '<td>',
                                    '<div class="unsolvedProblemElement">',
                                        
                                        '<textarea type="text" class="textare" id="problemKey_${Id}"></textarea>',
                                    '</div>',
                                '</td>',
                                '<td>',
                                    '<div class="unsolvedProblemElement"><a id="problemSubmit_${Id}">Submit</a></div>',
                                '</td>',
                                '<td>',
                                    '<img id="loadingImg_${Id}" src="images/ani_loading_small.gif"></img>',
                                    '<div id="msg_${Id}" class="display-none">',
                                        '<span id="msgDetail" class="msgDetails"></span>',
                                        '<span class="sign">&nbsp!</span>',
                                    '</div>',
                                '</td>',
                            '</tr>',
                          "{{/each}}"];
            
            var templateHtml = markup.join('');
            var table = ['<table>', templateHtml, '</table>'];

            return table.join('');
        },
        bindSubmitLinks: function () {
            $("#submitScoreContent a").click(function () {
                var link = $(this);
                var problemId = link.attr("id").replace("problemSubmit_", "");
                var problemKeyInput = $("#problemKey_" + problemId);
                var param = {
                    problemId: problemId,
                    key: problemKeyInput.val()
                };
                var loadingImage = $("#loadingImg_" + problemId);
                loadingImage.show();
                postDataToService("SubmitProblem", param, function (data) {
                    data = data.SubmitProblemResult;
                    if (data.Success) {
                        var div = $("#problem_" + problemId);
                        div.hide(300, null, function () {
                            div.remove();
                        });
                    }
                    else {
                        var msgDiv = $("#msg_" + problemId);
                        msgDiv.addClass('unsolvedProblemElement');
                        var msgDetail = msgDiv.children('#msgDetail');
                        msgDetail.html(data.ErrorMessage);
                        msgDiv.show();
                    }
                    loadingImage.hide();
                });
            });
        },
        clearElements: function () {
            var mainContainer = $("#divDynamicContents");
            mainContainer.children().hide();

            var submitProblemPanel = $("#submitScoreContent");
            submitProblemPanel.empty();
        },
        loadUnSolvedProbelms: function () {
            var scope = this;
            var submitProblemPanel = $("#submitScoreContent");

            getDataFromService("GetUnsolavedProblem", null, function (response) {
                $.template("soreBoardTemplate1", tab.getHmlTemplate());
                var html = $.tmpl("soreBoardTemplate1", response, {
                    getEllipsesName: function (name) {
                        
                    }
                }).html();
                tab.clearElements();
                submitProblemPanel.html(html);
                tab.bindSubmitLinks();

                var tabContent = $("#submitScoreTabContent");
                tabContent.show();

            }, scope, false);
        }
    };
    return tab;
};
    


