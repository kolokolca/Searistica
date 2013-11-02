<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Default.aspx.cs" Inherits="NewByteKnight.Default" %>

<asp:Content ID="Content2" ContentPlaceHolderID="divDynamicContentsPlaceHolder" runat="server">
    
    <script type="text/javascript" src="Scripts/Plugins/paperjs-v0.9.9/dist/paper.js"></script>
    <script src="Scripts/Application/default.js" type="text/paperscript" canvas="myCanvas"></script>
    <script src="Scripts/Plugins/JqPlum/jquery.jsPlumb-1.5.3-min.js" type="text/javascript"></script>

    <img alt="" class="dataLoading" src="images/loading.gif" id="loading" />
    <canvas id="myCanvas" style="background-color: #1C1C1C;"></canvas>
    <div id="menuhover">
    </div>
    <div id="menuContainer">
        <div id="options" class="options">
            Options</div>
        <div id="loadData" class="menuIteam">
            Load DFO Data</div>
        <div id="randGraph" class="menuIteam">
            Get Random Cost Graph</div>
        <div id="Div2" class="menuIteam">
            Apply Shortest Path Planing</div>
        <div id="Div3" class="menuIteam">
            Run Solvers</div>
    </div>
    <div class="graphViewerContent" style="display: none">
     <img alt="" class="closeImg" src="images/close.png" style="z-index: 130;"  id="Img1" />
    </div>
</asp:Content>
