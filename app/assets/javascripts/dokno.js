function copyToClipboard(text) {
  window.prompt('Copy to clipboard: CTRL+C, Enter', text);
}

function elem(selector) {
  return document.querySelector(selector);
}

function sendRequest(url, data, callback, method) {
  const request = new XMLHttpRequest();
  request.open(method, url, true);
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

function deactiveArticle(slug) {
  const callback = function(_data) {
    elem('button#article-deactivate-button').classList.add('hidden');
    elem('button#article-activate-button').classList.remove('hidden');
  }
  sendRequest(dokno__base_path + 'article_status', { slug: slug, active: false }, callback, 'POST');
}

function activeArticle(slug) {
  const callback = function(_data) {
    elem('button#article-activate-button').classList.add('hidden');
    elem('button#article-deactivate-button').classList.remove('hidden');
  }
  sendRequest(dokno__base_path + 'article_status', { slug: slug, active: true }, callback, 'POST');
}

function deleteArticle(id) {
  if (!confirm('Permanently Delete Article\n\nAre you sure you want to permanently delete this article?\n\nThis is irreversible.')) {
    return true;
  }

  const callback = function(_data) {
    location.href = dokno__base_path;
  }
  console.log(id);
  sendRequest(dokno__base_path + 'articles/' + id, {}, callback, 'DELETE');
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
  sendRequest(dokno__base_path + 'article_preview', { markdown: markdown }, callback, 'POST');
}

function writeArticleToggle() {
  elem('div#dokno-content-container textarea#markdown').classList.remove('hidden');
  elem('div#dokno-content-container a#markdown_preview_link').classList.remove('hidden');
  elem('div#dokno-content-container div#markdown_preview').classList.add('hidden');
  elem('div#dokno-content-container a#markdown_write_link').classList.add('hidden');
}

function toggleVisibility(selector_id) {
  var $elem = elem('#' + selector_id);
  var $icon = elem('svg.' + selector_id);
  var icon_class, new_icon;

  if ($elem.classList.contains('hidden')) {
    $elem.classList.remove('hidden');
    icon_class = 'chevron-down';
  } else {
    $elem.classList.add('hidden');
    icon_class = 'chevron-left';
  }

  new_icon = document.createElement('i');
  new_icon.setAttribute('data-feather', icon_class);
  new_icon.classList.add('inline');
  new_icon.classList.add('toggle-visibility-indicator');
  new_icon.classList.add(selector_id);

  $icon.remove();
  elem('div.toggle-visibility-indicator-container.' + selector_id).appendChild(new_icon);
  initIcons();
}
