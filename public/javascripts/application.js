// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function arraysearch(arr, i) {
    for (var index = 0, len = arr.length; index < len; ++index) {
	if (arr[index] == i) {
	    return true;
	}
    }
    return false;
}

CategoryView = Class.create();
CategoryView.prototype = {
    initialize: function() {
	this.visiblecats = [];
    },

    click: function(id) {
	if (arraysearch(this.visiblecats, id)) {
	    /* Visible - hide it. */
	    Element.update('category' + id, "");
	    this.visiblecats = this.visiblecats.without(id);
	} else {
	    /* Not visible - show it. */
	    this.visiblecats.push(id);
	    new Ajax.Updater('category' + id, '/search/expand/' + id,
			     {asynchronous:true, evalScripts:true});
	}
    }

};

function markdownpopup() {
    newwindow=window.open('http://daringfireball.net/projects/markdown/syntax','name',
			  'height=480,width=800,scrollbars=yes');
   if (window.focus) {
	newwindow.focus()
   }
   return false;
}

function check_all(checkbox) {
    var form = checkbox.form, z = 0;
    for(z=0; z<form.length;z++){
	if(form[z].type == 'checkbox' && form[z].name != 'checkall'){
	    form[z].checked = checkbox.checked;
	}
    }
}
