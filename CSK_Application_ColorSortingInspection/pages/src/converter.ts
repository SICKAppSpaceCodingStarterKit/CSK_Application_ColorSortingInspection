export function convertToList(value) {
  return JSON.parse(value)
}

export function invertStatusString(value) {
  return value == 'true' ? false: true
}

export function changeID(id) {
  const viewerElement = document.getElementById('Viewer2D1');
  viewerElement.setAttribute('viewer-id', id);
  viewerElement.triggerResume();
  return id;
}