var _submitScoreTab = null;
var _scorBoardTab = null;


var LoadData = function () {
    var obj = {
        dimension: null,
        load: function () {
            var scope = this;
            getDataFromService("GetCurrentDataDimension", null, function (response, textStatus, jqXHR, context) {
                debugger;
                context.dimension = response.Data;
                context.loadCellVector();
            }, scope, false);
        },
        loadCellVector: function () {
            var scope = this;
            getDataFromService("GetAllCellVector", null, function (response, textStatus, jqXHR, context) {
                var i = 0;
                context.drawCenterPoints(response.Data);
            }, scope, false);

        },
        drawSelectedCellAt: function (cell) {
            //if (cell.selectedCell == null) {
            var selectedCell = new Path.Circle({
                center: cell.position,
                radius: 8
            });
            selectedCell.strokeColor = '#0000FF';
            selectedCell.strokeWidth = 2;
            selectedCell.fillColor = '#04B404';
            selectedCell.onClick = function (event) {
                this.remove();
                //context.handleCellClick(this);
            };
            //}
            //cell.selectedCell.remove();
        },
        handleCellClick: function (cell) {
            debugger;
            this.drawSelectedCellAt(cell);
        },
        drawCenterPoints: function (cellVectors) {
            var scale = 30;
            var viewPortCenterX = $(window).width() / 2;
            var viewPortCenterY = $(window).height() / 2;
            var shiftX = viewPortCenterX - scale * this.dimension.MaxX / 2;
            var shiftY = viewPortCenterY - scale * this.dimension.MaxY / 2;

            //            var c1 = new Path.Circle(new Point(viewPortCenterX, viewPortCenterY), 10);
            //            c1.strokeColor = 'black';

            //            var c2 = new Path.Circle(new Point(shiftX, shiftY), 10);
            //            c2.strokeColor = 'black';

            //            var rectangle = new Rectangle(new Point(0, 0), new Point(this.dimension.MaxX * scale + shiftX, this.dimension.MaxY * scale + shiftY));
            //            var path = new Path.Rectangle(rectangle);
            //            path.fillColor = '#e9e9ff';
            //            path.selected = true;
            debugger;
            var extraHeight = 450;
            var offset = 20;
            var scaleX = parseInt(($(window).width() / 1.8) / this.dimension.MaxX, 10) ;
            var scaleY = parseInt(($(window).height() + extraHeight) / this.dimension.MaxY, 10);

            var contentDiv = $(".content");
            var size = new Size(contentDiv.width(), contentDiv.height() + extraHeight);
            project.view.viewSize = size;


            for (var index in cellVectors) {
                //var v = paperScope.view;
                var cellVector = cellVectors[index];
                var cell = new Path.Circle(new Point(cellVector.X * scaleX + offset, cellVector.Y * scaleY + offset), 4);
                cell.strokeColor = 'black';
                cell.fillColor = '#424242';
                //cell.opacity = 0.1;
                var context = this;
                cell.onClick = function (event) {
                    //this.remove();
                    context.handleCellClick(this);
                };

            }


            $("#loading").hide();
        }


    };
    return obj;
};

//function onMouseDown(event) {
//    debugger;
//    var hitOptions = {
//        segments: true,
//        stroke: true,
//        fill: true,
//        tolerance: 5
//    };


//    var hitResult = project.hitTest(event.point, hitOptions);
//    if (hitResult) {
//        if (hitResult.item) {
//            if (hitResult.item.isSelected == false) {
//                var selectedCell = new Path.Circle({
//                    center: event.point,
//                    radius: 4
//                });
//                selectedCell.strokeColor = 'black';
//                selectedCell.strokeWidth = 2;
//                selectedCell.fillColor = 'blue';
//                selectedCell.isSelected = true;
//                hitResult.item = selectedCell;
//            }
//            else {

//                var noramlCell = new Path.Circle({
//                    center: event.point,
//                    radius: 2
//                });
//                noramlCell.strokeColor = 'black';
//                noramlCell.isSelected = false;
//                hitResult.item = noramlCell;
//            }
//            
//            //cell.center = new Point(0, 0);
//        }
//    }
////    if (!hitResult)
////        return;

////    if (event.modifiers.shift) {
////        if (hitResult.type == 'segment') {
////            hitResult.segment.remove();
////        };
////        return;
////    }

////    if (hitResult) {
////        path = hitResult.item;
////        if (hitResult.type == 'segment') {
////            segment = hitResult.segment;
////        } else if (hitResult.type == 'stroke') {
////            var location = hitResult.location;
////            segment = path.insert(location.index + 1, event.point);
////            path.smooth();
////        }
////    }
////    movePath = hitResult.type == 'fill';
////    if (movePath)
////        project.activeLayer.addChild(hitResult.item);
//}

function setProjectViewSize(size) {
    
}

$(function () {
    debugger;
    
    var windowWidth = $(window).width();
    var windowHeight = $(window).height();

    var marginForScrollbar = 20;
    $(".nano").width(windowWidth - marginForScrollbar);
    $(".nano").height(windowHeight);
    $(".nano").nanoScroller();
    
    var contentDiv = $(".content");
    contentDiv.width(windowWidth - marginForScrollbar);
    contentDiv.height(windowHeight);

    var viewPortCenterX = contentDiv.width() / 2;
    var viewPortCenterY = contentDiv.height() / 2;
    $("#loading").offset({ top: viewPortCenterY, left: viewPortCenterX });

    $("#loadData").click(function () {
        $("#loading").show();
        new LoadData().load();

    });

    //    $(".tabHeader ul li a").click(function () {
    //        $("*").removeClass("active");
    //        var link = $(this);
    //        link.addClass("active");
    //        if (link.attr("id") == "submitProblem") {
    //            if (_submitScoreTab == null)
    //                _submitScoreTab = new SubmitScoreTab();

    //            _scorBoardTab.clearTimer();
    //            _submitScoreTab.loadUnSolvedProbelms();
    //        }
    //        if (link.attr("id") == "scoreBoard") {
    //            if (_scorBoardTab == null)
    //                _scorBoardTab = new ScoreBoardTab();
    //            _scorBoardTab.show();
    //        }
    //    });

    //    getDataFromService("GetTeamName ", null, function (response) {
    //        $("#teamName").html(response.Data);
    //        if (_scorBoardTab == null) {
    //            _scorBoardTab = new ScoreBoardTab();
    //            _scorBoardTab.show();
    //        }
    //    });
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
    


