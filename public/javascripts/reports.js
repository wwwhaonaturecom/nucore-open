/**
 * A query string of all params necessary to issue a report.
 * @params
 * A variable number of additional parameter Arrays.
 * Each Array is expected to be length 2 where index
 * 0 holds the name of a parameter and index 1 holds
 * a value. These will be appended to the end of the
 * default query string.
 */

// get a query string with the most current report parameters
function getQueryString()
{
    var paramString='?' + $('#refresh-form').serialize();

    for(var param in arguments)
        paramString += ('&' + param);

    return paramString;
}


// update the given url with the most current report parameters
function updateUrl(url)
{
    var pageParam=url.match(/page=\d+/);

    if(pageParam != null)
        return url.substring(0, url.indexOf('?')) + getQueryString(pageParam[0]);

    return url + getQueryString();
}


// update and return the currently selected tab's URL
function getUpdateTabUrl(ui) { return updateUrl($.data(ui.tab, 'load.tabs')); }


function initGeneralReportsUI(selectedIndex)
{
    // create reports tabs
    $('#tabs').tabs({
        selected: selectedIndex,

        select: function(event, ui) {
            // before refreshing tab update the tab's URL with the current report params
            var url=getUpdateTabUrl(ui);
            $('#tabs').tabs('url', ui.index, url);
        },

        load: function(event, ui) {
            // every time a tab loads make sure the export urls are set to export current report
            var url=getUpdateTabUrl(ui);
            $('#export').attr('href', url + '&export_id=general_report&format=csv');
            $('#export-all').attr('href', url + '&export_id=general_report_data&format=csv');
        },

        ajaxOptions: {
            error: function(xhr, status, error) {
                $('#error-msg').html('Sorry, but the tab could not load. Please try again soon.').show();
            }
        }
    });

    // handle pagination requests
    $('.pagination a').live('click',function (){
        var selected=$('#tabs').tabs('option', 'selected');
        $('#tabs').tabs('url', selected, this.href).tabs('load', selected);
        return false;
    });

    // update report on parameter change
    $('#refresh-form :input').change(function() {
        var selected=$('#tabs').tabs('option', 'selected');
        $('#tabs').tabs('url', selected, updateUrl(window.location.pathname)).tabs('load', selected);
    });
}

$(document).ready(function() {
    $('.datepicker').each(function() {
      $(this).datepicker();
    });
});