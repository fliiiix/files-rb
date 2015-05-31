var $ = function (id) { return document.getElementById(id); };
function enableUpload() {
  var uploadInput = $('uploadInput');
  if (uploadInput.value != ''){
    $('uploadDiv').style.display = 'none';
    $('selectedFileDiv').style.display = '';
     
    //remove span content and add the file name
    var filenameSpan = $('filename');
    while( filenameSpan.firstChild ) {
      filenameSpan.removeChild( filenameSpan.firstChild );
    }
    filenameSpan.appendChild( document.createTextNode(uploadInput.value) );
  }
}
   
function selectNewFile() {
  $('uploadDiv').style.display = '';
  $('selectedFileDiv').style.display = 'none';
  $('uploadInput').value = '';
}

function toglePassword(){
  var checked = $('protected').checked;
  if(checked)
  {
    $('name').disabled = false;
    $('password').disabled = false;
  }
  else
  {
    $('name').disabled = true;
    $('password').disabled = true;
  }
}