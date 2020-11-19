function copyToClipboard(text) {
  window.prompt('Copy to clipboard: CTRL+C, Enter', text);
}

function elem(selector) {
  return document.querySelector(selector);
}

function postRequest(url, data, callback) {
  const request = new XMLHttpRequest();
  request.open('POST', url, true);
  request.setRequestHeader('X-CSRF-Token', elem('meta[name="csrf-token"]').getAttribute('content'));
  request.setRequestHeader('Content-Type', 'application/json');
  request.onload = function() {
    if (request.readyState == 4 && request.status == 200) {
      try {
        var data = JSON.parse(request.responseText);
      } catch(err) {
        console.log(err.message + " in " + request.responseText);
        return;
      }

      callback(data);
    }
  };

  request.send(JSON.stringify(data));
}

function previewArticleToggle() {
  const markdown = elem('div#dokno-content-container textarea#markdown').value;
  const callback = function(data) {
    elem('div#dokno-content-container div#markdown_preview').innerHTML = data.parsed_content;
    elem('div#dokno-content-container textarea#markdown').classList.add('hidden');
    elem('div#dokno-content-container a#markdown_preview_link').classList.add('hidden');
    elem('div#dokno-content-container div#markdown_preview').classList.remove('hidden');
    elem('div#dokno-content-container a#markdown_write_link').classList.remove('hidden');
  }
  postRequest(dokno__base_path + 'article_preview', { markdown: markdown }, callback);
}

function writeArticleToggle() {
  elem('div#dokno-content-container textarea#markdown').classList.remove('hidden');
  elem('div#dokno-content-container a#markdown_preview_link').classList.remove('hidden');
  elem('div#dokno-content-container div#markdown_preview').classList.add('hidden');
  elem('div#dokno-content-container a#markdown_write_link').classList.add('hidden');
}
