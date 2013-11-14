var DataVisualizer = function () {
    var obj = {
        dimension: null,
        selectedPoints: {},
        totalSelectedPoints: 0,
        getAreaOfSelectedPoints: function () {
            var area = { minX: screen.width, minY: screen.height, maxX: 0, maxY: 0 };
            for (var index in this.selectedPoints) {
                var selectedPoint = this.selectedPoints[index];

                if (selectedPoint.X < area.minX) area.minX = selectedPoint.X;
                if (selectedPoint.Y < area.minY) area.minY = selectedPoint.Y;

                if (selectedPoint.X > area.maxX) area.maxX = selectedPoint.X;
                if (selectedPoint.Y > area.maxY) area.maxY = selectedPoint.Y;

            }
            return area;
        },
        getSelectedPoints: function () {
            var points = [];
            for (key in this.selectedPoints) {
                var point = this.selectedPoints[key];
                points.push(point);
            }
            return points;
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
        clearPreviousDraw: function () {
            var previousCells = $('.cell');
            previousCells.remove();
        },
        drawCellMeanVectors: function (cellVectors, context) {
            context.clearTimer();

            context.clearPreviousDraw();
            var extraHeight = screen.height * (62 / 100);
            var offset = 20;
            var scaleX = parseInt((screen.width / 1.5) / this.dimension.MaxX, 10);
            var scaleY = parseInt((screen.height + extraHeight) / this.dimension.MaxY, 10);

            //var context = this;
            var container = $('#dataVisualize');
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

                var cellX = cellVector.X * scaleX + offset;
                var cellY = cellVector.Y * scaleY + offset;
                var cell = obj.createNewCell(cellX, cellY, cellVector.X, cellVector.Y, container);

                //                var cellXY = new paper.Point(cellVector.X * scaleX + offset, cellVector.Y * scaleY + offset);
                //                var cell = new paper.Path.Circle(cellXY, 4);
                //                cell.strokeColor = '#1C1C1C';
                //                cell.strokeWidth = 3;
                //                cell.fillColor = '#424242';
                //                cell.cellVectorX = cellVector.X;
                //                cell.cellVectorY = cellVector.Y;
                //                cell.originalPosition = { X: cellVector.X, Y: cellVector.Y };
                //                //cell.opacity = 0.1;
                //                //cell.visible = false;
                //                cell.onClick = function (event) {
                //                    context.selectedPoints.push(this.originalPosition);
                //                    context.handleCellClick(this);
                //                };

                cell.click(function () {
                    var c = $(this);
                    var x = c.attr('x');
                    var y = c.attr('y');
                    var cellPos = { X: x, Y: y };
                    var key = x + "_" + y;

                    if (c.hasClass('selectedCell')) {
                        c.removeClass('selectedCell');
                        delete context.selectedPoints[key];
                        context.totalSelectedPoints -= 1;
                    }
                    else {
                        c.addClass('selectedCell');
                        context.selectedPoints[key] = cellPos;
                        context.totalSelectedPoints += 1;
                    }
                    //alert(x + ' ' + y);
                });

            }
            $("#loading").hide();
        },
        createNewCell: function (x, y, originalX, originalY, container) {
            var cell = $('<div class="cell"></div>');
            cell.css({ left: x - 3, top: y - 3 });
            cell.attr('x', originalX);
            cell.attr('y', originalY);
            cell.appendTo(container);
            return cell;
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