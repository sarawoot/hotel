// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require bootstrap-datetimepicker/bootstrap-datetimepicker
//= require bootstrap-datepicker
//= require select2
//= require easyui/jquery.easyui.min
//= require underscore/underscore-min

function remove_fields(link) {
    $(link).prev("input[type=hidden]").val("1");
    $(link).closest(".fields").hide();
}

function add_fields(link, association, content, modal) {
    var new_id = new Date().getTime();
    var regex = new RegExp("new_" + association, "g");
    $(link).parent().after(content.replace(regex, new_id));
    $('#'+modal).modal('show');
}

function pad(num, size) {
    var s = num+"";
    while (s.length < size) s = "0" + s;
    return s;
}


function add_tables(link, association, content,table) {
    var new_id = new Date().getTime();
    var regex = new RegExp("new_" + association, "g");
    $("#"+table).append(content.replace(regex, new_id))
}

function remove_table(link) {
    $(link).prev("input[type=hidden]").val("1");
    $(link).closest("tr").hide();
}

var rowBuilder = function(cfg) {
    
    this.appendFields = function() {
        var row = $('<tr>', { class: 'fields' });                                         
        var buildRow = function(fields) {
            var newRow = row.clone();
            $(fields).map(function() {
                $(this).removeAttr('class');
                $('<td/>').append($(this)).appendTo(newRow);
            })
            
            var link = $('<a>', {
                href: '#',
                onclick: 'remove_fields(this); return false;',
                title: 'Delete this Pilot.'
            }).append($('<i>', { class: 'icon-remove' }));
            link.appendTo(newRow[0].lastChild)
            return newRow;
        }
        var attachRow = function(tableBody, fields) {
            var row = buildRow(fields);
            $(row).appendTo($(tableBody));
        }            
        var inputFields = $(cfg.formId + ' ' + cfg.inputFieldClassSelector);
        inputFields.detach();
        attachRow(this.getTBodySelector(), inputFields);
    }
        
    this.hideForm = function() {
        $(cfg.formId).modal('hide');
        $(cfg.formId).remove();
    }
    
    this.getTBodySelector =  function() {
        return cfg.tableId + ' tbody';
    }
    
    this.init = function(){
        me = this;
        $(cfg.addButton).on('click', function() {
            me.appendFields();
            me.hideForm();
        });
        
        $(cfg.closeButton).on('click', function() {
            me.hideForm();
        });
        
        $(cfg.cancelButton).on('click', function() {
            me.hideForm();
        }); 
    }
    

};  
