<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Default.aspx.cs" Inherits="NewByteKnight.Default" %>

<asp:Content ID="Content2" ContentPlaceHolderID="divDynamicContentsPlaceHolder" runat="server">
    <script type="text/javascript" src="Scripts/Plugins/paperjs-v0.9.9/dist/paper.js"></script>
    <script src="Scripts/Plugins/JqPlum/jquery.jsPlumb-1.5.3-min.js" type="text/javascript"></script>
    <script src="Scripts/Application/DataVisualizer.js" type="text/javascript"></script>
    <script src="Scripts/Application/default.js" type="text/paperscript" canvas="myCanvas"></script>
    <img alt="" class="dataLoading" src="images/loading.gif" id="loading" />
    <div id="dataVisualize">
        <canvas id="myCanvas" style="background-color: #1C1C1C;"></canvas>
    </div>
    <div id="menuhover">
    </div>
    <div id="menuContainer">
        <div id="options" class="options">
            Options</div>
        <div id="loadData" class="menuIteam" style="cursor: pointer">
            1. Load Ocean Current Data</div>
        <div id="selectPoint" class="menuIteam">
            2. Select Points to Be Visited
            <div id="selectRandomPoint" class="subMenuIteam">
                Select Random Number Of Points</div>
            <div id="selectPointManually" class="subMenuIteam">
                Select Points Manually</div>
        </div>
        <div id="createNewProject" class="menuIteam" style="cursor: pointer">
            3. Create a new project</div>
        <div id="generateGraph" class="menuIteam">
            4. Generate Fully Connected Graph
            <div id="randGraph" class="subMenuIteam">
                Random Cost Graph</div>
            <div id="edGraph" class="subMenuIteam">
                Euclidean Cost Graph</div>
            <div id="Div2" class="subMenuIteam">
                Graph By Applying Shortest Path Planing</div>
        </div>
        <div id="runSolver" class="menuIteam" style="cursor: pointer">
            5. Run Solvers</div>
    </div>
    <div id='graphViewerContent'>
        <img alt='' class='closeImg' src='images/close.png' id='Img1' />
        <img alt='' class='graphLoading' src='images/294_2.gif' id='graphLoading' />
        <%--<div class='statusbar'>
            <div class='statusContainer'>
                <img alt='not found' src='images/statusback.png' class='statusbarBackImage' />
                <div class="solverLoadingDiv">
                    <img alt='not found' src='images/285.gif' class='solverLoading' />
                    <div class="solverName">
                        SAT4J Solver</div>
                </div>
                <div class="statusBarText1">
                    Running Psuedo Boolean Solver on backend server . . .</div>
                <div class="statusBarText3">
                    Graph:
                    <div style="padding-left: 10px; display: inline-block">
                        Having
                        <div id="nodeCount">
                            4 Nodes</div>
                        and
                        <div id="edgeCount">
                            12 Edges.</div>
                    </div>
                </div>
                <div class="statusBarText3">
                    Timeout for solver:
                    <div style="padding-left: 10px; display: inline-block">
                        <div id="timer">
                            4 min.
                        </div>
                    </div>
                </div>
            </div>
        </div>--%>
        <div class='graphContainer'>
        </div>
        <div class='runSolverBtn'>
            <div class='runSolverText'>
                Run Solver
            </div>
        </div>
    </div>
    <div id="projectCreationWindowContent">
        <img alt='' class='closeImg' src='images/close.png' id='Img2' />
        <div class="projectNameTitle">
            Create a New Project</div>
        <div class="inlineBlock projectNameContainer">
            <div class="inlineBlock tahoma15">
                Project Name:
            </div>
            <div class="inlineBlock">
                <input type="text" id="projectName" />
            </div>
            <div id="projectNameOKbtn" class="inlineBlock projectNameOKbtn">
                OK
            </div>
        </div>
    </div>
    <div id="statusWindowContent">
        <img alt='' class='closeImg' src='images/close.png' id='Img4' />
        <div id="statusText" style="color: white" class="tahoma15">
            Status</div>
        <img alt='' class='graphLoading statusLoading' src='images/294_2.gif' id='Img3' />
    </div>
</asp:Content>
