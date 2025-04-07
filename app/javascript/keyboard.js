document.addEventListener('DOMContentLoaded', function() {
  const textInput = document.getElementById('text-input');
  const letterKeyboard = document.getElementById('letter-keyboard');
  const numberKeyboard = document.getElementById('number-keyboard');
  const toggleButton = document.getElementById('keyboard-toggle');
  const toggleButtonNum = document.getElementById('keyboard-toggle-num');

  function addActiveClass(element) {
    element.classList.add('active');
    setTimeout(() => element.classList.remove('active'), 100);
  }

  function handleKeyClick(e) {
    const key = e.target.closest('.key');
    if (!key || key.classList.contains('key-toggle')) return;
    
    addActiveClass(key);
    const keyValue = key.dataset.key;
    
    switch(keyValue) {
      case 'backspace':
        textInput.value = textInput.value.slice(0, -1);
        break;
      case 'enter':
        textInput.value += '\n';
        break;
      default:
        textInput.value += keyValue;
    }
    
    textInput.scrollTop = textInput.scrollHeight;
  }

  function toggleKeyboard() {
    letterKeyboard.classList.toggle('hidden');
    numberKeyboard.classList.toggle('hidden');
  }

  letterKeyboard.addEventListener('click', handleKeyClick);
  numberKeyboard.addEventListener('click', handleKeyClick);

  toggleButton.addEventListener('click', (e) => {
    addActiveClass(e.target);
    toggleKeyboard();
  });
  
  toggleButtonNum.addEventListener('click', (e) => {
    addActiveClass(e.target);
    toggleKeyboard();
  });

  document.querySelectorAll('.key').forEach(key => {
    if (!key.querySelector('span')) {
      const text = key.textContent;
      key.innerHTML = `<span>${text}</span>`;
    }
  });
}); 
