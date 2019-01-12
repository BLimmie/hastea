$(document).ready(function() {
    $(":text:visible:enabled:first").focus();
});

function verifyPasswordMatch(form) {
  if (form.password.value == form.password2.value) {
    return true;
  } else {
    alert("The passwords do not match.");
    return false;
  }
}
function verifyFileTypes(form) {
  if(form.documentation.value!=""){
    if(form.documentation.value.match(/\.([^\.]+)$/)[1].toLowerCase() != "pdf"){
      alert("Documentation file type is invalid")
      return false;
    }
    if(form.documentation.files[0].size/1024/1024>5){
      alert("Documentation must be less than 5MB")
      return false;
    }
  }
  else if(form.drawing.value!=""){
    if(form.drawing.value.match(/\.([^\.]+)$/)[1].toLowerCase() != "pdf"){
        alert("Drawing file type is invalid")
        return false;
    }
    if(form.drawing.files[0].size/1024/1024>5){
      alert("Drawing must be less than 5MB")
      return false;
    }
  }
  else if(form.toolpath.value!=""){
      if(form.toolpath.value.match(/\.([^\.]+)$/)[1].toLowerCase() != "gcode"){
        alert("Toolpath file type is invalid")
        return false;
      }
      if(form.toolpath.files[0].size/1024/1024>5){
        alert("Toolpath must be less than 5MB")
        return false;
      }
  }
  else {
    return true;
  }
}
var VendorID;
function changeVendorPartFilter(vendorID) {
  VendorID = vendorID;
  loadVendorParts();
}
function loadVendorParts() {
  $.ajax({
    url: "/vendors/" + VendorID + "/parts",
    complete: function(response) {
      $("#vendor_parts").html(response.responseText);
      $("#vendor_parts").tooltip({
        selector: ".vendor-part",
        placement: "bottom"
      });
    }
  });
}

// Global variables to store current filter state for auto-refresh.
var dashboardProjectId, dashboardStatus;

function changeDashboardFilter(projectId, status) {
  dashboardProjectId = projectId;
  dashboardStatus = status;
  loadParts();
}

function loadParts() {
  $.ajax({
    url: "/projects/" + dashboardProjectId + "/dashboard/parts?status=" + dashboardStatus,
    complete: function(response) {
      $("#dashboard-parts").html(response.responseText);
      $("#dashboard-parts").tooltip({
        selector: ".dashboard-part",
        placement: "bottom"
      });
    }
  });
}

function vendorAutoComplete(selector) {
  $(selector).typeahead({
    source: vendors
  });
}

// Only allow editing one item at a time.
var editingOrderItem = false;

function editOrderItem(projectId, orderItemId) {
  if (editingOrderItem) {
    alert("Can only edit one item at a time.");
    return;
  }
  editingOrderItem = true;
  $.ajax({
    url: "/projects/" + projectId + "/order_items/" + orderItemId + "/editable",
    complete: function(response) {
      $("#order-item-" + orderItemId).html(response.responseText);
      vendorAutoComplete("#edit-vendor");
      $("#edit-vendor").focus();
    }
  });
}

$(function() {
  vendorAutoComplete("#vendor");
  $(".datepicker").datepicker();
});
