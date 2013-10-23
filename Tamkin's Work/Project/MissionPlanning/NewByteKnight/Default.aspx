<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Default.aspx.cs" Inherits="NewByteKnight.Default" %>

<asp:Content ID="Content2" ContentPlaceHolderID="divDynamicContentsPlaceHolder" runat="server">
    <script src="Scripts/Application/default.js" type="text/javascript"></script>
    <div class="menu tabHeader">
        <div class="center">
            <ul id="ulMenuList">
                <li><a id="scoreBoard" href="#a" class="active">Score Board</a></li>
                <li><a id="submitProblem" href="#a">Submit your solution</a></li>
                <li><a href="#a">About</a></li>
            </ul>
            <div class="teamN">
                <span style="font-size: 10px; color:Gray">Log in as :</span> <span id="teamName"></span>
            </div>
        </div>
    </div>
    <div id="divDynamicContents">
        <div id="scoreBoardTabContent" class="tabContent display-none">
            <div id="scoreBoardContent">
            </div>
        </div>
        <div id="submitScoreTabContent" class="tabContent display-none">
            <div id="submitScoreContent">
            </div>
        </div>
    </div>
</asp:Content>
