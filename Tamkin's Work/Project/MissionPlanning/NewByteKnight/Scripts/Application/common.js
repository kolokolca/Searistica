function getDataFromService(operationName, paramvalue, successfunc, scope, isCache) {
    $.ajax({
        type: "GET",
        url: getServiceUrl(operationName),
        data: paramvalue,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        processdata: true,
        cache: isCache,
        success: function (data, textStatus, jqXHR) {
            successfunc(data, textStatus, jqXHR, scope);
        },
        error: serviceFailed
    });
}

function postDataToService(operationName, paramvalue, successfunc, scope) {
    $.ajax({
        type: "POST",
        url: getServiceUrl(operationName),
        data: JSON.stringify(paramvalue),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        processdata: true,
        success: function (data, textStatus, jqXHR) {
            successfunc(data, textStatus, jqXHR, scope);
        },
        error: serviceFailed
    });
}

function getServiceUrl(methodName) {
    return 'Service/Service.svc/' + methodName;
};

function serviceFailed(result) {
    alert('Service call failed: ' + result.status + '' + result.statusText);
}

function operationFailed() {
    alert('Failed');
}

function showGlobalLoading() {
    var loadingDiv = $('<div class="globalLoading" style="z-index: 1050;">LOADING .....</div>');
    loadingDiv.css({ left: 160, top: 150 });
    loadingDiv.appendTo(document.body);
}

function hideGlobalLoading() {
    var loading = $(".globalLoading");
    if (loading) {
        loading.remove();
    }
}

$.fn.showLoading = function () {
    var element = $(this);
    var pos = element.position();
    var width = element.outerWidth(true);
    var height = element.outerHeight(true);

    var loadingDiv = $('<div class="globalLoading" style="z-index: 1050;">LOADING .....</div>');
    loadingDiv.css({ left: 150, top: 100 });
    loadingDiv.appendTo(element);
};

$.fn.hideLoading = function () {
    var element = $(this);
    element.find(".globalLoading").remove();
};