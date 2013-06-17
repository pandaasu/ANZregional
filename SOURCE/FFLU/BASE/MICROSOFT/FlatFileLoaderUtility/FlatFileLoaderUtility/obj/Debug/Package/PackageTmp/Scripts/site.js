// Models

var Status = function () {
    this.CurrentStep = 1;
    this.TotalSteps = 5;
    this.IsError = false;
    this.Message = "";
    this.Exception = "";
    this.InterfaceCode = "";
    this.FileName = "";
    this.FilePath = "";
    this.FileSize = 0;
    this.MaxRowSize = 4000;
    this.SegmentBytes = 0;
    this.SegmentCount = 0;
    this.TotalLength = 0;
    this.ProcessedLength = 0;
    this.Remainder = ""; // Used for modern browsers
    this.File = null; // Used for IE
    this.UploadId = 0;
    this.LicsId = 0;
    this.NeedsEncodingFix = false;
    this.InterfaceErrorCount = 0;
    this.RowErrorCount = 0;
    this.DanglingChar = ""; // Used for utf-16 -> utf-8 fix for IE where lower byte of character may need to be deferred to the following segment
};


// Data Operations

function GetInterfaceOptions(interfaceGroupCode, interfaceTypeCode, $list, isProcessRequired, isMonitorRequired) {

    if (!CheckIdentifierForOptions(interfaceGroupCode, $list))
        return;

    FillOptionsList(
        "GetInterfaceOptions",
        {
            interfaceGroupCode: interfaceGroupCode,
            interfaceTypeCode: interfaceTypeCode,
            isProcessRequired: isProcessRequired,
            isMonitorRequired: isMonitorRequired
        },
        $list
    );
}


// Misc Functions

function setEnabledOfDialogButton($button, enabled, buttonText) {
    if (!$button) {
        return;
    }

    if (enabled != false) {
        $button.removeAttr('disabled').removeClass('ui-state-disabled');
    } else {
        $button.attr('disabled', 'disabled').addClass('ui-state-disabled');
    }

    if (buttonText) {
        $button.find('span').text(buttonText);
    }
}

function FillOptionsList(url, postData, $list, value) {
    $.ajax({
        type: "post",
        url: "/Base/" + url,
        data: postData,
        xhrFields: {
            withCredentials: true
        },
        success: function (response) {
            if (response.Result == "OK") {
                $list.empty();
                $list[0].selectedIndex = -1;
                $list.append($("<option value=''>- select -</option>"));
                $.each(response.Options, function (index, item) {
                    $list.append($("<option></option>").val(item.Value).html(item.DisplayText));
                });
                if (value != null)
                    $list.val(value);
                else if (response.Options.length == 1)
                    $list.val($list.find("option:eq(1)").val());
                $list.change();
                $list.trigger("liszt:updated");
                if (response.Options.length == 0)
                    $list.attr("disabled", "disabled");
                else
                    $list.removeAttr("disabled");
            }
            else {
                alert("Error: " + response.Message);
            }
        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert("Error communicating with server." + ((isTest) ? " Exception: " + thrownError : ""));
        }
    });
}

function CheckIdentifierForOptions(id, $list) {
    if (id == "") {
        $list.empty();
        $list.append($("<option value=''>- select -</option>"));
        $list.change();
        return false;
    }
    else {
        return true;
    }
}

function addCommas(nStr) {
    nStr += '';
    x = nStr.split('.');
    x1 = x[0];
    x2 = x.length > 1 ? '.' + x[1] : '';
    var rgx = /(\d+)(\d{3})/;
    while (rgx.test(x1)) {
        x1 = x1.replace(rgx, '$1' + ',' + '$2');
    }
    return x1 + x2;
}

// Helps for resetting file input fields
function resetFormElement(e) {
    e.wrap("<form>").closest("form").get(0).reset();
    e.unwrap();
}