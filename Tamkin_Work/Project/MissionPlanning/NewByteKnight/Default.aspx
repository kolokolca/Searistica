<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Default.aspx.cs" Inherits="NewByteKnight.Default" %>

<asp:Content ID="Content2" ContentPlaceHolderID="divDynamicContentsPlaceHolder" runat="server">
    <script type="text/javascript" src="Scripts/Plugins/paperjs-v0.9.9/dist/paper.js"></script>
    <script src="Scripts/Application/default.js" type="text/paperscript" canvas="myCanvas"></script>
    <script src="Scripts/Plugins/naoScroll/jquery.nanoscroller.js" type="text/javascript"></script>
    <div class="menu tabHeader">
        <div class="center">
            <ul id="ulMenuList">
                <li><a id="loadData" href="#a" class="active" style="position: absolute; left:100; top:100; z-index: 100">Load DFO data</a></li>
                <%--<li><a id="submitProblem" href="#a">Submit your solution</a></li>
                <li><a href="#a">About</a></li>--%>
            </ul>
        </div>
    </div>
    <%--<div id="divDynamicContents">
        <div id="scoreBoardTabContent" class="tabContent display-none">
            <div id="scoreBoardContent">
            </div>
        </div>
        <div id="submitScoreTabContent" class="tabContent display-none">
            <div id="submitScoreContent">
            </div>
        </div>
    </div>--%>

    <img alt="" src="images/loading.gif" style="width: 50px; height:50px; z-index:100; display:none" id="loading"/>
    <div class="nano" style="position: absolute; left:0; top:0">
        <div class="content" style="background-color: #1C1C1C; overflow: auto; position:absolute">
            <canvas id="myCanvas" resize></canvas>
        </div>
    </div>
</asp:Content>
