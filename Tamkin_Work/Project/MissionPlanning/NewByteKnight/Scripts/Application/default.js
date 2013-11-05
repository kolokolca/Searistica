var graphViewerObj = null;
var dataVisualizer = null;
var obj = null;

var DataVisualizer = function () {
    var obj = {
        dimension: null,
        selectedPoints: new Array(),
        getAreaOfSelectedPoints: function () {
            var area = { minX: screen.width, minY: screen.height, maxX: 0, maxY: 0 };

            for (var index in this.selectedPoints) {
                var selectedPoint = this.selectedPoints[index];

                if (selectedPoint.X < area.minX) area.minX = selectedPoint.X;
                if (selectedPoint.Y < area.minY) area.minY = selectedPoint.Y;

                if (selectedPoint.X > area.maxX) area.maxX = selectedPoint.X;
                if (selectedPoint.Y > area.maxY) area.maxY = selectedPoint.Y;

            }
            debugger;
            return area;
        },
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
                var data = response.Data;
                //context.drawCellMeanVectorAfterInterval(2, data, context);
                context.drawCellMeanVectors(data, context);
            }, scope, false);

        },
        drawCellMeanVectorAfterInterval: function (sec, data, context) {
            if (context.clearIntervalId == null)
                context.clearIntervalId = window.setInterval(function () {
                    context.drawCellMeanVectors(data, context);
                }, 1000 * sec);
        },
        clearIntervalId: null,
        drawSelectedCellAt: function (cell) {
            var selectedCell = new paper.Path.Circle({
                center: cell.position,
                radius: 5
            });
            selectedCell.strokeColor = '#FA8258';
            selectedCell.strokeWidth = 2;
            selectedCell.fillColor = '#04B404';
            selectedCell.onClick = function (event) {
                this.remove();
            };
        },
        handleCellClick: function (cell) {
            this.drawSelectedCellAt(cell);
        },
        drawCellMeanVectors: function (cellVectors, context) {
            context.clearTimer();
            var extraHeight = screen.height * (62 / 100);
            var offset = 20;
            var scaleX = parseInt((screen.width / 1.5) / this.dimension.MaxX, 10);
            var scaleY = parseInt((screen.height + extraHeight) / this.dimension.MaxY, 10);

            //var context = this;
            for (var index in cellVectors) {

                var cellVector = cellVectors[index];

                var vectorStart = new paper.Point(cellVector.X * scaleX + offset, cellVector.Y * scaleY + offset);
                var scalingVector = 280;
                var vectorEnd = new paper.Point(vectorStart.x + cellVector.U * scalingVector, vectorStart.y + cellVector.V * scalingVector * -1);

                var vector = vectorEnd - vectorStart;
                var arrowVector = vector.normalize(5);
                var end = vectorStart + vector;
                var vectorItem = new paper.Group([
		                            new paper.Path([vectorStart, end]),
		                            new paper.Path([end + arrowVector.rotate(135), end, end + arrowVector.rotate(-135)])
                                 ]);
                vectorItem.strokeWidth = 1;
                vectorItem.strokeColor = '#0080FF';

                var cellXY = new paper.Point(cellVector.X * scaleX + offset, cellVector.Y * scaleY + offset);
                var cell = new paper.Path.Circle(cellXY, 4);
                cell.strokeColor = '#1C1C1C';
                cell.strokeWidth = 3;
                cell.fillColor = '#424242';
                cell.cellVectorX = cellVector.X;
                cell.cellVectorY = cellVector.Y;
                cell.originalPosition = { X: cellVector.X, Y: cellVector.Y };
                //cell.opacity = 0.1;
                //cell.visible = false;
                cell.onClick = function (event) {
                    context.selectedPoints.push(this.originalPosition);
                    context.handleCellClick(this);
                };
            }
            $("#loading").hide();
        },
        clearTimer: function () {
            if (obj.clearIntervalId) {
                window.clearInterval(obj.clearIntervalId);
                obj.clearIntervalId = null;
            }
        }
    };
    return obj;
};

var GraphViewer = function () {
    var obj = {
        clearIntervalId: null,
        createNode: function (id) {
            var html = "<div class='w' id='n" + id + "'>" +
                     id + "</div>";
            return $(html);
        },
        createGraphNodes: function (grapViewerWindow) {
            debugger;
            var area = dataVisualizer.getAreaOfSelectedPoints();
            var rowColumnGap = 5;
            var width = area.maxX - area.minX + rowColumnGap;
            var height = area.maxY - area.minY + rowColumnGap;
            var graphViewerWindow = $(".graphViewerWindow");
            var containerOffset = 100;
            var widthFactor = parseInt((graphViewerWindow.width() - containerOffset) / width, 10);
            var heightFactor = parseInt((graphViewerWindow.height() - containerOffset) / height, 10);

            for (var index in dataVisualizer.selectedPoints) {
                var selectedPoint = dataVisualizer.selectedPoints[index];
                var nodeName = parseInt(index, 10) + 1;
                var nodeDiv = this.createNode(nodeName);
                nodeDiv.css('left', ((selectedPoint.X - area.minX) * widthFactor) + rowColumnGap * widthFactor / 2 + containerOffset / 2);
                nodeDiv.css('top', ((selectedPoint.Y - area.minY) * heightFactor) + rowColumnGap * heightFactor / 2 + containerOffset / 2);
                nodeDiv.appendTo(grapViewerWindow);
            }
        },
        setPosition: function (grapViewerWindow) {

            var menuContainer = $('#menuContainer');
            var viewPort = {
                width: screen.width - menuContainer.width(),
                height: screen.height,
                centerX: (screen.width - menuContainer.width()) / 2,
                centerY: screen.height / 2
            };
            var percentOfWidthGap = viewPort.width * 10 / 100;
            var percentOfHeightGap = viewPort.height * 7 / 100;

            grapViewerWindow.offset({
                top: percentOfHeightGap,
                left: percentOfWidthGap
            });

            var halfHeight = viewPort.centerY - percentOfHeightGap;
            var halfWidth = viewPort.centerX - percentOfWidthGap;

            var height = halfHeight * 2;
            var width = halfWidth * 2;

            grapViewerWindow.height(height);
            grapViewerWindow.width(width);

            var loading = $("#graphLoading");
            var loadingImgW = parseInt(loading.css('width').replace("px", ""), 10);

            loading.offset({ top: 25 , left: width / 2 - (loadingImgW / 2) });
            loading.show();

            var closeicon = $('.closeImg');
            closeicon.click(function () {
                var view = $(".graphViewerWindow");
                view.remove();

            });

        },
        startGraphGeneration: function (grapViewerWindow, level, jsPlumbInstance) {
            var context = this;
            if (context.clearIntervalId == null)
                context.clearIntervalId = window.setInterval(function () {
                    context.generateGraph(grapViewerWindow, context, level, jsPlumbInstance);
                }, 1000 * 1);
        },
        clearTimer: function () {
            if (this.clearIntervalId) {
                window.clearInterval(obj.clearIntervalId);
                this.clearIntervalId = null;
            }
        },
        getLoadingImage: function () {
            var img = " <img class='graphLoading' src='images/294_1.gif' id='graphLoading' />";
            return $(img);
        },
        getCloseImage: function () {
            var img = " <img class='closeImg' src='images/close.png' style='z-index: 130;' id='Img1' />";
            return $(img);
        },

        view: function () {

            var grapViewerWindow = $('<div></div>');
            grapViewerWindow.addClass('graphViewerWindow');

            this.getCloseImage().appendTo(grapViewerWindow);
            this.getLoadingImage().appendTo(grapViewerWindow);

            grapViewerWindow.appendTo($('body'));
            this.setPosition(grapViewerWindow);

            grapViewerWindow.draggable();
            grapViewerWindow.show();

            this.createGraphNodes(grapViewerWindow);
            var jsPlumbInstance = jsPlumb.getInstance({
                Endpoint: ["Dot", { radius: 2}],
                HoverPaintStyle: { strokeStyle: "#1e8151", lineWidth: 2 },
                ConnectionOverlays: [
                                        ["Arrow", {
                                            location: 1,
                                            id: "arrow",
                                            length: 10,
                                            foldback: 0.8
                                        }],
                                        ["Label",
                                            {
                                                id: "label",
                                                cssClass: "aLabel"
                                            }]
                                ]
            });

            this.startGraphGeneration(grapViewerWindow, 1, jsPlumbInstance);

        },
        generateGraph: function (grapViewerWindow, context, level, jsPlumbInstance) {

            context.clearTimer();

            jsPlumb.Defaults.Container = grapViewerWindow;
            var windows = $(".w");
            jsPlumbInstance.draggable(windows, {
                containment: $('.graphViewerWindow')
            });

            jsPlumbInstance.bind("connection", function (info) {
                var params = info.connection.getParameters();
                info.connection.getOverlay("label").setLabel(params.cost.toString());
            });


            jsPlumbInstance.doWhileSuspended(function () {

                jsPlumbInstance.makeSource(windows, {
                    isSource: false,
                    anchor: "Continuous",
                    connector: ["Straight"],
                    connectorStyle: { strokeStyle: "#585858", lineWidth: 1, outlineColor: "transparent", outlineWidth: 4 },
                    maxConnections: 1,
                    onMaxConnections: function (info, e) {
                        //alert("Maximum connections (" + info.maxConnections + ") reached");
                        return false;
                    },
                    ReattachConnections: false,
                    ConnectionsDetachable: false
                });

                var i = level;
                for (var j = 1; j <= dataVisualizer.selectedPoints.length; j++) {
                    if (i == j) continue;
                    var s = "n" + i;
                    var t = "n" + j;
                    var randomCost = Math.floor((Math.random() * 20) + 1);
                    jsPlumbInstance.connect({ source: s, target: t, parameters: { "cost": randomCost} });
                }

            });

            if (level == dataVisualizer.selectedPoints.length) {
                var loading = $("#graphLoading");
                loading.hide();
            }
            else {
                var nextLevel = level + 1;
                this.startGraphGeneration(grapViewerWindow, nextLevel, jsPlumbInstance);
            }

        }
    };
    return obj;
};



function initializeCanvasView() {
    var windowWidth = screen.width;     //$(window).width();
    var windowHeight = screen.height;   //$(window).height();
    var marginForScrollbar = 20;
    var extraHeight = screen.height * (62 / 100);
    var size = new paper.Size(windowWidth - marginForScrollbar, windowHeight + extraHeight);
    project.view.viewSize = size;
}

function initializeMenuContainer() {
    var menuHover = $("#menuhover");
    var width = 200;
    var browserScrollBarWidth = 18;
    menuHover.offset({ top: 0, left: screen.width - width - browserScrollBarWidth });
    menuHover.width(width);
    menuHover.height(screen.height);

    var menuContainer = $('#menuContainer');
    menuContainer.offset({ top: 0, left: screen.width });
    menuContainer.width(300);
    menuContainer.height(screen.height);

    menuHover.mouseenter(function () {
        menuContainer.show();
        menuContainer.animate({
            left: screen.width - menuContainer.width() - browserScrollBarWidth
        }, 500);
    });
    menuContainer.mouseleave(function () {
        menuContainer.animate({
            left: screen.width
        }, 500);

    });
}

function initializeLoadingIamges() {
    var menuContainer = $('#menuContainer');
    var viewPortCenterX = (screen.width - menuContainer.width()) / 2;
    var viewPortCenterY = screen.height / 2;
    $("#loading").offset({ top: viewPortCenterY, left: viewPortCenterX });
}

function handleMenuClick() {
    $("#loadData").click(function () {
        $("#loading").show();
        project.activeLayer.remove();
        project.activeLayer = new paper.Layer();
        dataVisualizer = new DataVisualizer();
        dataVisualizer.load();

    });
    $("#randGraph").click(function () {
        graphViewerObj.view();
    });
}

$(function () {
    graphViewerObj = new GraphViewer();
    initializeCanvasView();
    initializeMenuContainer();
    handleMenuClick();
    initializeLoadingIamges();
});

    


