const dokno__search_hotkey_listener = function(e) {
  if (e.key === '/') { handleSearchHotKey(); }
}

function handleSearchHotKey() {
  const search_input = elem('input#search_term');
  search_input.focus();
  search_input.select();
}

function enableSearchHotkey() {
  document.addEventListener('keyup', dokno__search_hotkey_listener, false);
}

function disableSearchHotkey() {
  document.removeEventListener('keyup', dokno__search_hotkey_listener, false);
}

function copyToClipboard(text) {
  window.prompt('Copy to clipboard: CTRL + C, Enter', text);
}

function elem(selector) {
  return document.querySelector(selector);
}

function elems(selector) {
  return document.getElementsByClassName(selector);
}

function selectOption(id, value) {
  var sel = elem('#' + id);
  var opts = sel.options;

  for (var opt, j = 0; opt = opts[j]; j++) {
    if (opt.value == value) {
      sel.selectedIndex = j;
      break;
    }
  }
}

function applyCategoryCriteria(category_code, term, order) {
  goToPage(dokno__base_path + category_code + '?search_term=' + term + '&order=' + order);
}

function goToPage(url) {
  var param_join = url.indexOf('?') >= 0 ? '&' : '?';
  location.href=url + param_join + '_=' + Math.round(new Date().getTime());
}

function reloadPage() {
  window.onbeforeunload = function () { window.scrollTo(0, 0); }
  location.reload();
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
      } catch(_e) {
        var data = request.responseText;
      }

      callback(data);
    }
  };

  request.send(JSON.stringify(data));
}

function deactivateArticle(slug) {
  const callback = function(_data) { reloadPage(); }
  sendRequest(dokno__base_path + 'article_status', { slug: slug, active: false }, callback, 'POST');
}

function activateArticle(slug) {
  const callback = function(_data) { reloadPage(); }
  sendRequest(dokno__base_path + 'article_status', { slug: slug, active: true }, callback, 'POST');
}

function deleteArticle(id) {
  if (!confirm('Permanently Delete Article\n\nAre you sure you want to permanently delete this article?\n\nThis is irreversible.')) {
    return true;
  }

  const callback = function(_data) {
    location.href = dokno__base_path;
  }
  sendRequest(dokno__base_path + 'articles/' + id, {}, callback, 'DELETE');
}

function deleteCategory(id) {
  if (!confirm('Delete Category\n\nThis will remove this category. Any articles in this category will become uncategorized and appear on the home page until re-categorized.')) {
    return true;
  }

  const callback = function(_data) {
    location.href = dokno__base_path;
  }
  sendRequest(dokno__base_path + 'categories/' + id, {}, callback, 'DELETE');
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

  if (!$elem) {
    return true;
  }

  if ($elem.classList.contains('hidden')) {
    $elem.classList.remove('hidden');
    icon_class = 'chevron-down';
  } else {
    $elem.classList.add('hidden');
    icon_class = 'chevron-left';
  }

  if (!$icon) {
    return true;
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

// Pass containers_selector as class name (no prefix)
function highlightTerm(terms, containers_selector) {
  var containers = elems(containers_selector);

  for (var i=0, len=containers.length|0; i<len; i=i+1|0) {
    var content = containers[i].innerHTML;

    terms.forEach(term => {
      content = content.replace(new RegExp(term, 'gi'), (match) => wrapTermWithHTML(match));
    });

    containers[i].innerHTML = content;
  }
}

function wrapTermWithHTML(term) {
  return `<span title="Matching search term" class="dokno-search-term bg-yellow-300 text-gray-900 p-2 rounded mx-1">${term}</span>`
}
