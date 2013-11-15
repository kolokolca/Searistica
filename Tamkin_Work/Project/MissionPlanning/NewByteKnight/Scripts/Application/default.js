
var _globalDataVisualizer = null;
var _utilityFunctions = null;


var GraphType = function () {
    var obj = {
        random: false,
        euclidean: false,
        pathPlanning: false,
        symmetric: false
    };
    return obj;
};

var DataVisualizer = function () {
    var obj = {
        dimension: null,
        selectedPoints: {},
        totalSelectedPoints: 0,
        ScallingProperties: null,
        getAreaOfSelectedPoints: function () {
            debugger;
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
            debugger;
            var points = [];
            for (key in this.selectedPoints) {
                var point = this.selectedPoints[key];
                points.push(point);
            }
            if (points.length == 0) {
                _utilityFunctions.showStatus('Please select some points to visit.', true, false);
                return null;
            }
            return points;
        },
        saveSelectedPoints: function () {
            var currentProjectname = _createProject.currentProjectName;
            var paramValue = {
                selectedPoints: obj.getSelectedPoints(),
                projectName: currentProjectname
            };

            _utilityFunctions.showStatus("Saving selected points.");
            postDataToService('SaveSelectedPoints', paramValue, function (response, status, xhr, scope) {
                _utilityFunctions.hideStatusWindow();
                response = response.SaveSelectedPointsResult;
                if (response.Data == false) {
                    _utilityFunctions.showStatus(response.ErrorMessage, true, false);
                    return;
                }
                _utilityFunctions.showStatus("' " + _createProject.currentProjectName + " ' project created.",true,false);
            }, scope);
        },
        generateRandomCostGraph: function () {
            _utilityFunctions.showStatus("Generating random cost graph.");
            var paramValue = {
                numberOfNodes: obj.totalSelectedPoints,
                projectName: _createProject.currentProjectName
            };
            postDataToService('GenerateRandomCostGraph', paramValue, function (response, status, xhr, scope) {
                _utilityFunctions.hideStatusWindow();
                response = response.GenerateRandomCostGraphResult;
                if (response.Success == false) {
                    _utilityFunctions.showStatus(response.ErrorMessage, true, false);
                    return;
                }
                _utilityFunctions.showStatus("Random cost graph generated.", true, false);
            }, scope);
        },
        generateEuclideanCostGraph: function () {

            _utilityFunctions.showStatus("Generating euclidean cost graph.");
            var paramValue = {
                numberOfNodes: obj.totalSelectedPoints,
                projectName: _createProject.currentProjectName
            };
            postDataToService('GenerateEuclideanDistanceCostGraph', paramValue, function (response, status, xhr, scope) {
                _utilityFunctions.hideStatusWindow();
                response = response.GenerateEuclideanDistanceCostGraphResult;
                if (response.Success == false) {
                    _utilityFunctions.showStatus(response.ErrorMessage, true, false);
                    return;
                }
                _utilityFunctions.showStatus("Euclidean cost graph generated.", true, false);
            }, scope);
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
            project.activeLayer.remove();
            project.activeLayer = new paper.Layer();
            var previousCells = $('.cell');
            previousCells.remove();
        },
        setScallingProperties: function (offset, scaleX, scaleY) {
            obj.ScallingProperties = {
                offset: offset,
                scaleX: scaleX,
                scaleY: scaleY
            };
        },
        drawCellMeanVectors: function (cellVectors, context) {
            context.clearTimer();
            var extraHeight = screen.height * (62 / 100);
            var offset = 20;
            var scaleX = parseInt((screen.width / 1.5) / this.dimension.MaxX, 10);
            var scaleY = parseInt((screen.height + extraHeight) / this.dimension.MaxY, 10);
            obj.setScallingProperties(offset, scaleX, scaleY);

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
                    var cellPos = { X: parseInt(x, 10), Y: parseInt(y, 10) };
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
        },
        runSolver: function (encodingFilename) {
            var totalNodes = _globalDataVisualizer.totalSelectedPoints;
            var totalEdges = Math.pow(totalNodes, 2) - totalNodes;
            _utilityFunctions.showStatus("Running solver on backend. Given graph has " + totalNodes + " nodes and " + totalEdges + " edges.");
            var paramValue = {
                encodingType: 'PB',
                projectName: _createProject.currentProjectName,
                encodingFilename: encodingFilename
            };
            postDataToService("RunSolver", paramValue, function (response, textStatus, jqXHR, context) {
                _utilityFunctions.hideStatusWindow();
                response = response.RunSolverResult;
                if (response.Success == false) {
                    _utilityFunctions.showStatus(response.ErrorMessage, true, false);
                    return;
                }
                obj.decodeSolverResult(response.Data);

            }, this, false);
        },
        decodeSolverResult: function (solverResultFileName) {

            _utilityFunctions.showStatus("Decoding solver result.");
            var paramValue = {
                encodingType: 'PB',
                projectName: _createProject.currentProjectName,
                solverResultFileName: solverResultFileName
            };
            postDataToService("DecodeSolverResult", paramValue, function (response, textStatus, jqXHR, context) {
                _utilityFunctions.hideStatusWindow();
                response = response.DecodeSolverResultResult;
                if (response.Success == false) {
                    _utilityFunctions.showStatus(response.ErrorMessage, true, false);
                    return;
                }
                obj.drawTour(response.Data);
            }, this, false);

        },
        getShiftedXPointOf: function (x) {
            return x * obj.ScallingProperties.scaleX + obj.ScallingProperties.offset;
        },
        getShiftedYPointOf: function (y) {
            return y * obj.ScallingProperties.scaleY + obj.ScallingProperties.offset;
        },
        drawTour: function (tourPoints) {
            debugger;
            //            for (index in tourPoints) {
            //                var tourPoint = tourPoints[index];
            //                var vectorStart = new paper.Point(obj.getShiftedXPointOf(tourPoint.X), obj.getShiftedYPointOf(tourPoint.Y));
            //                var vectorEnd = new paper.Point(obj.getShiftedXPointOf(tourPoint.U), obj.getShiftedYPointOf(tourPoint.V));

            //                var vector = vectorEnd - vectorStart;
            //                var arrowVector = vector.normalize(20);
            //                var end = vectorStart + vector;
            //                var vectorItem = new paper.Group([
            //		                            new paper.Path([vectorStart, end]),
            //		                            new paper.Path([end + arrowVector.rotate(135), end, end + arrowVector.rotate(-135)])
            //                                 ]);
            //                vectorItem.strokeWidth = 3;
            //                vectorItem.strokeColor = '#FF0000';

            //            }
            new TourViewer().view(tourPoints);
        },
        generateEncoding: function () {
            var paramValue = {
                encodingType: 'PB',
                projectName: _createProject.currentProjectName,
                costMatrixFileName: 'EuclideanDistanceCostmatrix'
            };

            _utilityFunctions.showStatus("Generating encoding.");

            postDataToService("GenerateEncoding", paramValue, function (response, textStatus, jqXHR, context) {
                debugger;
                _utilityFunctions.hideStatusWindow();
                response = response.GenerateEncodingResult;
                if (response.Success == false) {
                    _utilityFunctions.showStatus(response.ErrorMessage, true, false);
                    return;
                }
                obj.runSolver(response.Data);
            }, this, false);
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
        createGraphNodes: function (graphViewerWindow) {
            debugger;
            var area = _globalDataVisualizer.getAreaOfSelectedPoints();
            var rowColumnGap = 5;
            var width = area.maxX - area.minX + rowColumnGap;
            var height = area.maxY - area.minY + rowColumnGap;
            var containerOffset = 100;
            var widthFactor = parseInt((graphViewerWindow.width() - containerOffset) / width, 10);
            var heightFactor = parseInt((graphViewerWindow.height() - containerOffset) / height, 10);

            var gaphContainer = graphViewerWindow.find('.graphContainer');
            var nodeName = 0;
            for (var index in _globalDataVisualizer.selectedPoints) {
                var selectedPoint = _globalDataVisualizer.selectedPoints[index];
                nodeName += 1;
                var nodeDiv = this.createNode(nodeName);
                nodeDiv.css('left', ((selectedPoint.X - area.minX) * widthFactor) + rowColumnGap * widthFactor / 2 + containerOffset / 2);
                nodeDiv.css('top', ((selectedPoint.Y - area.minY) * heightFactor) + rowColumnGap * heightFactor / 2 + containerOffset / 2);
                nodeDiv.appendTo(gaphContainer);
            }
        },
        setPosition: function (graphViewerWindow) {

            var menuContainer = $('#menuContainer');
            var viewPort = {
                width: screen.width - menuContainer.width(),
                height: screen.height,
                centerX: (screen.width - menuContainer.width()) / 2,
                centerY: screen.height / 2
            };

            var percentOfWidthGap = viewPort.width * 10 / 100;
            var percentOfHeightGap = viewPort.height * 7 / 100;

            graphViewerWindow.offset({
                top: percentOfHeightGap,
                left: percentOfWidthGap
            });

            var halfHeight = viewPort.centerY - percentOfHeightGap;
            var halfWidth = viewPort.centerX - percentOfWidthGap;

            var height = halfHeight * 2;
            var width = halfWidth * 2;

            graphViewerWindow.height(height);
            graphViewerWindow.width(width);

            var loading = graphViewerWindow.find("#graphLoading");
            var loadingImgW = 125;

            loading.show();
            loading.offset({ top: 25, left: width / 2 - (loadingImgW / 2) });


            var closeicon = graphViewerWindow.find('.closeImg');
            closeicon.click(function () {
                obj.handleClose();
            });

        },
        handleClose: function () {
            var view = $(".graphViewerWindow");
            view.remove();
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
        showRunSolverButton: function () {
            var graphViewerWindow = $('.graphViewerWindow');
            graphViewerWindow.draggable();

            var button = graphViewerWindow.find('.runSolverBtn');
            button.appendTo(graphViewerWindow);

            button.offset({ top: graphViewerWindow.height() - 60, left: graphViewerWindow.width() - 135 });
            button.show();

            button.click(function () {
                alert('Run solver !');
                obj.runSolverOnSever();
            });
        },
        createGraphViewerWindow: function () {
            var graphViewerWindow = $("<div class='graphViewerWindow'></div>");
            graphViewerWindow.html(this.getGraphViewerWindowContent());
            this.setPosition(graphViewerWindow);
            graphViewerWindow.appendTo($('body'));
            return graphViewerWindow;
        },
        getGraphViewerWindowContent: function () {
            var content = $("#graphViewerContent").html();
            return content;
        },
        view: function (graphType) {
            debugger;
            var grapViewerWindow = this.createGraphViewerWindow();
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
        runSolverOnSever: function () {
            getDataFromService("RunSolverOnServer", null, function (response, textStatus, jqXHR, context) {
                debugger;
            }, this, false);
        },
        generateGraph: function (grapViewerWindow, context, level, jsPlumbInstance) {

            context.clearTimer();

            jsPlumb.Defaults.Container = grapViewerWindow.find('.graphContainer');
            var windows = $(".w");
            //            jsPlumbInstance.draggable(windows, {
            //                containment: $('.graphViewerWindow')
            //            });

            jsPlumbInstance.bind("connection", function (info) {
                var params = info.connection.getParameters();
                info.connection.getOverlay("label").setLabel(params.cost.toString());
            });

            jsPlumbInstance.doWhileSuspended(function () {

                jsPlumbInstance.makeSource(windows, {
                    isSource: false,
                    anchor: "Continuous",
                    connector: ["StateMachine", { curviness: 20}],
                    connectorStyle: { strokeStyle: "#585858", lineWidth: 1, outlineColor: "transparent", outlineWidth: 4 },
                    maxConnections: 1,
                    onMaxConnections: function (info, e) {
                        //alert("Maximum connections (" + info.maxConnections + ") reached");
                        return false;
                    },
                    ReattachConnections: false,
                    ConnectionsDetachable: false
                });
                debugger;

                var i = level;
                for (var j = 1; j <= _globalDataVisualizer.totalSelectedPoints; j++) {
                    if (i == j) continue;
                    var s = "n" + i;
                    var t = "n" + j;
                    var randomCost = Math.floor((Math.random() * 20) + 1);
                    jsPlumbInstance.connect({ source: s, target: t, parameters: { "cost": randomCost} });
                }

            });

            if (level == _globalDataVisualizer.totalSelectedPoints) {
                var view = $(".graphViewerWindow");
                var loading = view.find("#graphLoading");
                loading.hide();
                context.showRunSolverButton();
            }
            else {
                var nextLevel = level + 1;
                this.startGraphGeneration(grapViewerWindow, nextLevel, jsPlumbInstance);
            }

        }
    };
    return obj;
};

var TourViewer = function () {
    var obj = {

        clearIntervalId: null,
        createNode: function (id) {
            var html = "<div class='w' id='n" + id + "'>" +
                     id + "</div>";
            return $(html);
        },
        createGraphNodes: function (graphViewerWindow, tourPoints) {
            var area = _globalDataVisualizer.getAreaOfSelectedPoints();
            var rowColumnGap = 3;
            var width = area.maxX - area.minX + rowColumnGap;
            var height = area.maxY - area.minY + rowColumnGap;
            var containerOffset = 70;
            var widthFactor = parseInt((graphViewerWindow.width() - containerOffset) / width, 10);
            var heightFactor = parseInt((graphViewerWindow.height() - containerOffset) / height, 10);
            var gaphContainer = graphViewerWindow.find('.graphContainer');
            var nodeName = 0;
            for (var index in tourPoints) {
                var tourPoint = tourPoints[index];

                nodeName += 1;
                tourPoint.id = tourPoints;

                var nodeDiv = this.createNode(nodeName);
                nodeDiv.css('left', ((tourPoint.X - area.minX) * widthFactor) + rowColumnGap * widthFactor / 2 + containerOffset / 2);
                nodeDiv.css('top', ((tourPoint.Y - area.minY) * heightFactor) + rowColumnGap * heightFactor / 2 + containerOffset / 2);
                nodeDiv.attr('nid', tourPoint.X + "_" + tourPoint.Y);
                nodeDiv.appendTo(gaphContainer);
            }
        },
        setPosition: function (graphViewerWindow) {

            var menuContainer = $('#menuContainer');
            var viewPort = {
                width: screen.width - menuContainer.width(),
                height: screen.height,
                centerX: (screen.width - menuContainer.width()) / 2,
                centerY: screen.height / 2
            };

            var percentOfWidthGap = viewPort.width * 10 / 100;
            var percentOfHeightGap = viewPort.height * 7 / 100;

            graphViewerWindow.offset({
                top: percentOfHeightGap,
                left: percentOfWidthGap
            });

            var halfHeight = viewPort.centerY - percentOfHeightGap;
            var halfWidth = viewPort.centerX - percentOfWidthGap;

            var height = halfHeight * 2;
            var width = halfWidth * 2;

            graphViewerWindow.height(height);
            graphViewerWindow.width(width);

            var loading = graphViewerWindow.find("#graphLoading");
            var loadingImgW = 125;

            loading.show();
            loading.offset({ top: 25, left: width / 2 - (loadingImgW / 2) });


            var closeicon = graphViewerWindow.find('.closeImg');
            closeicon.click(function () {
                obj.handleClose();
            });

        },
        handleClose: function () {
            var view = $(".graphViewerWindow");
            view.remove();
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
        showRunSolverButton: function () {
            var graphViewerWindow = $('.graphViewerWindow');
            graphViewerWindow.draggable();

            var button = graphViewerWindow.find('.runSolverBtn');
            button.appendTo(graphViewerWindow);

            button.offset({ top: graphViewerWindow.height() - 60, left: graphViewerWindow.width() - 135 });
            button.show();

            button.click(function () {
                alert('Run solver !');
                obj.runSolverOnSever();
            });
        },
        createGraphViewerWindow: function () {
            var graphViewerWindow = $("<div class='graphViewerWindow'></div>");
            graphViewerWindow.html(this.getGraphViewerWindowContent());
            this.setPosition(graphViewerWindow);
            graphViewerWindow.appendTo($('body'));
            return graphViewerWindow;
        },
        getGraphViewerWindowContent: function () {
            var content = $("#graphViewerContent").html();
            return content;
        },
        view: function (tourPoints) {

            var grapViewerWindow = this.createGraphViewerWindow();
            grapViewerWindow.show();
            grapViewerWindow.draggable();
            
            this.createGraphNodes(grapViewerWindow, tourPoints);

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

            debugger;
            this.generateGraph(grapViewerWindow, this, tourPoints, jsPlumbInstance);

        },
        runSolverOnSever: function () {
            getDataFromService("RunSolverOnServer", null, function (response, textStatus, jqXHR, context) {
                debugger;
            }, this, false);
        },
        generateGraph: function (grapViewerWindow, context, tourPoints, jsPlumbInstance) {

            jsPlumb.Defaults.Container = grapViewerWindow.find('.graphContainer');

            var windows = $(".w");

            jsPlumbInstance.draggable(windows, {
                containment: $('.graphViewerWindow')
            });

            jsPlumbInstance.bind("connection", function (info) {
                var params = info.connection.getParameters();
                info.connection.getOverlay("label").setLabel(params.cost.toString());
            });

            jsPlumbInstance.doWhileSuspended(function () {
                debugger;
                jsPlumbInstance.makeSource(windows, {
                    isSource: false,
                    anchor: "Continuous",
                    connector: ["StateMachine", { curviness: 20}],
                    connectorStyle: { strokeStyle: "#585858", lineWidth: 1, outlineColor: "transparent", outlineWidth: 4 },
                    maxConnections: 1,
                    onMaxConnections: function (info, e) {
                        //alert("Maximum connections (" + info.maxConnections + ") reached");
                        return false;
                    },
                    ReattachConnections: false,
                    ConnectionsDetachable: false
                });


                for (index in tourPoints) {
                    var tourPoint = tourPoints[index];
                    var sId = tourPoint.X + "_" + tourPoint.Y;
                    var tId = tourPoint.U + "_" + tourPoint.V;

                    var s = $(".w[nid =" + sId + "]");
                    var t = $(".w[nid =" + tId + "]");

                    jsPlumbInstance.connect({ source: s, target: t, parameters: { "cost": 1} });
                }

                grapViewerWindow.find('.graphLoading').hide();
            });
        }
    };
    return obj;
};

var CreateProject = function () {

    var obj = {
        currentProjectName: null,
        setWindowPosition: function (window) {
            var menuContainer = $('#menuContainer');
            var viewPort = {
                width: screen.width - menuContainer.width(),
                height: screen.height,
                centerX: (screen.width - menuContainer.width()) / 2,
                centerY: screen.height / 2
            };
            var winWidth = 350;
            var winHeight = 120;

            window.offset({
                top: viewPort.centerY - winHeight / 2,
                left: viewPort.centerX - winWidth / 2
            });
        },
        showWindow: function () {

            var selectedPoints = _globalDataVisualizer.getSelectedPoints();
            if (selectedPoints == null) {
                return;
            }

            var projectCreationWindow = $("<div class='projectCreationWindow'></div>");
            projectCreationWindow.html(this.getWindowContent());
            this.setWindowPosition(projectCreationWindow);
            projectCreationWindow.appendTo($('body'));

            var closeicon = projectCreationWindow.find('.closeImg');
            closeicon.click(function () {
                obj.handleClose();
            });

            var okBtn = projectCreationWindow.find('.projectNameOKbtn');
            okBtn.click(function () {
                obj.createProject();
            });

            projectCreationWindow.show();
            var textBox = projectCreationWindow.find('#projectName');
            textBox.focus();

        },
        getWindowContent: function () {
            var content = $("#projectCreationWindowContent").html();
            return content;
        },
        handleClose: function () {
            var view = $(".projectCreationWindow");
            view.remove();
        },
        createProject: function () {
            var scope = this;
            var window = $('.projectCreationWindow');
            var textBox = window.find('#projectName');
            this.currentProjectName = textBox.val();
            var paramValue = {
                projectName: this.currentProjectName
            };

            window.remove();
            _utilityFunctions.showStatus("Creating a new project.");

            postDataToService('CreateNewProject', paramValue, function (response, status, xhr, scope) {
                _utilityFunctions.hideStatusWindow();
                response = response.CreateNewProjectResult;
                var success = response.Data;
                if (!success) {
                    _utilityFunctions.showStatus(response.ErrorMessage, true, false);
                    return;
                }
                _globalDataVisualizer.saveSelectedPoints();
            }, scope);
        }

    };

    return obj;
};

var UtilityFunctions = function () {

    var obj = {
        getStatusWindowContent: function () {
            var contentDiv = $('#statusWindowContent');
            return contentDiv.html();
        },
        setStatusWindowPosition: function (statusWindow) {
            var menuContainer = $('#menuContainer');
            var viewPort = {
                width: screen.width - menuContainer.width(),
                height: screen.height,
                centerX: (screen.width - menuContainer.width()) / 2,
                centerY: screen.height / 2
            };
            var winWidth = 325;
            var winHeight = 120;

            statusWindow.offset({
                top: viewPort.centerY - winHeight / 2,
                left: viewPort.centerX - winWidth / 2
            });
        },
        addStatusWindowCloseButton: function (window, closeable) {
            var img = window.find('.closeImg');
            if (closeable == null || closeable == undefined) {
                img.remove();
                return;
            }
            img.click(function () {
                window.remove();
            });
        },
        addStatusWindowLoading: function (window, showLoading) {

            if (showLoading == null || showLoading == undefined) {
                return;
            }
            if (showLoading == false) {
                var loading = window.find('.statusLoading');
                loading.remove();
            }
        },
        showStatus: function (message, closeable, showLoading) {
            debugger;
            var currentStatusWindow = $('.statusWindow');
            if (currentStatusWindow)
                currentStatusWindow.remove();

            var statusWindow = $("<div class='statusWindow'></div>");
            statusWindow.html(this.getStatusWindowContent());
            var statusTextDiv = statusWindow.find('#statusText');
            statusTextDiv.html(message);
            this.addStatusWindowCloseButton(statusWindow, closeable);
            this.addStatusWindowLoading(statusWindow, showLoading);

            this.setStatusWindowPosition(statusWindow);
            statusWindow.appendTo($('body'));

            statusWindow.show();
        },
        hideStatusWindow: function () {
            var currentWindow = $('.statusWindow');
            currentWindow.remove();
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

    var menuWidth = 340;
    var menuContainer = $('#menuContainer');
    menuContainer.offset({ top: 0, left: screen.width - menuWidth });
    menuContainer.width(menuWidth);
    menuContainer.height(screen.height);
    menuContainer.show();

    //    menuHover.mouseenter(function () {
    //        menuContainer.show();
    //        menuContainer.animate({
    //            left: screen.width - menuContainer.width() - browserScrollBarWidth
    //        }, 500);
    //    });
    //    menuContainer.mouseleave(function () {
    //        menuContainer.animate({
    //            left: screen.width
    //        }, 500);

    //    });
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
        _globalDataVisualizer.clearPreviousDraw();
        _globalDataVisualizer.load();

    });
    //    $("#randGraph").click(function () {
    //        _globalGraphViewerObj.view();
    //    });
    $("#selectPointManually").click(function () {
        //_utilityFunctions.showStatus("Generating random cost function graph.");
    });
    $("#randGraph").click(function () {
        _globalDataVisualizer.generateRandomCostGraph()();
    });
    $("#edGraph").click(function () {
        _globalDataVisualizer.generateEuclideanCostGraph()();
    });
    $("#createNewProject").click(function () {
        _createProject.showWindow();
    });
    $("#runSolver").click(function () {

        _globalDataVisualizer.generateEncoding();
    });

}

$(function () {
    _globalDataVisualizer = new DataVisualizer();
    _utilityFunctions = new UtilityFunctions();
    _createProject = new CreateProject();

    initializeCanvasView();
    initializeMenuContainer();
    handleMenuClick();
    initializeLoadingIamges();
});

    


