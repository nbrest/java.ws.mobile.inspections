/**
 * Newsletter functions.
 */
function main() {
  importNewsletter();
}

/**
 * Import newsletter content.
 */
function importNewsletter() {
  domUtils.append($('head'), '<link rel="stylesheet" type="text/css" href="/kame-house/css/snippets/newsletter.css">');
  $("#newsletter").load("/kame-house/html-snippets/newsletter.html");
}

/**
 * Call main.
 */
$(document).ready(main);