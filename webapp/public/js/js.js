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
