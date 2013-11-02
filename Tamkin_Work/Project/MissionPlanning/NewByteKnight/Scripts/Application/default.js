var graphViewerObj = null;

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
                //cell.opacity = 0.1;
                //cell.visible = false;
                cell.onClick = function (event) {
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
        positionCalculatedBefore: false,
        view: function () {

            var grapViewerWindow = $('<div></div>');
            var graphViewerContent = $('.graphViewerContent');
            grapViewerWindow.addClass('graphViewerWindow');
            grapViewerWindow.html(graphViewerContent.html());
            grapViewerWindow.appendTo($('body,html'));

            //            if (this.positionCalculatedBefore) {
            //                grapViewer.show();
            //                return;
            //            }

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

            grapViewerWindow.height(halfHeight * 2);
            grapViewerWindow.width(halfWidth * 2);

            var closeicon = $('.closeImg');
            closeicon.click(function () {
                var view = $(".graphViewerWindow");
                view.remove();

            });

            grapViewerWindow.draggable();
            grapViewerWindow.show();
            this.positionCalculatedBefore = true;
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
        new LoadData().load();

    });
    $("#randGraph").click(function () {
        debugger;
        graphViewerObj.view();
    });
}
$(function () {
    graphViewerObj = new GraphViewer();

    initializeCanvasView();
    initializeMenuContainer();
    handleMenuClick();
    initializeLoadingIamges();

    jsPlumb.bind("ready", function () {
        alert(1);
    });

});

    


