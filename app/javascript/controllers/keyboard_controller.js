import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.setupKeyboard();
  }

  setupKeyboard() {
    const textInput = document.getElementById('text-input');
    const letterKeyboard = document.getElementById('letter-keyboard');
    const numberKeyboard = document.getElementById('number-keyboard');
    const toggleButton = document.getElementById('keyboard-toggle');
    const toggleButtonNum = document.getElementById('keyboard-toggle-num');

    let backspaceTimer = null;
    const initialDelay = 500;
    const repeatDelay = 100;

    function deleteCharacter() {
      if (textInput.value.length > 0) {
        textInput.value = textInput.value.slice(0, -1);
        textInput.scrollTop = textInput.scrollHeight;
      }
    }

    function startRepeatingDelete() {
      deleteCharacter();
      backspaceTimer = setInterval(deleteCharacter, repeatDelay);
    }

    function stopRepeatingDelete() {
      if (backspaceTimer) {
        clearInterval(backspaceTimer);
        backspaceTimer = null;
      }
    }

    function handleBackspacePress(e) {
      e.preventDefault();
      deleteCharacter();
      
      let pressTimer = setTimeout(() => {
        startRepeatingDelete();
      }, initialDelay);

      const handleRelease = (e) => {
        clearTimeout(pressTimer);
        stopRepeatingDelete();
        document.removeEventListener('mouseup', handleRelease);
        document.removeEventListener('touchend', handleRelease);
      };

      document.addEventListener('mouseup', handleRelease);
      document.addEventListener('touchend', handleRelease);
    }

    function handleKeyClick(e) {
      const key = e.target.closest('.key');
      if (!key || key.classList.contains('key-toggle')) return;
      
      const keyValue = key.dataset.key;
      
      key.classList.add('active');
      setTimeout(() => key.classList.remove('active'), 100);

      if (keyValue === 'backspace') {
        return;
      }
      
      switch(keyValue) {
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

    document.querySelectorAll('.key[data-key="backspace"]').forEach(backspaceKey => {
      backspaceKey.addEventListener('mousedown', handleBackspacePress);
      backspaceKey.addEventListener('touchstart', handleBackspacePress, { passive: false });
    });

    toggleButton.addEventListener('click', (e) => {
      e.target.classList.add('active');
      setTimeout(() => e.target.classList.remove('active'), 100);
      toggleKeyboard();
    });
    
    toggleButtonNum.addEventListener('click', (e) => {
      e.target.classList.add('active');
      setTimeout(() => e.target.classList.remove('active'), 100);
      toggleKeyboard();
    });

    document.querySelectorAll('.key').forEach(key => {
      if (!key.querySelector('span')) {
        const text = key.textContent;
        key.innerHTML = `<span>${text}</span>`;
      }
    });

    document.addEventListener('touchmove', (e) => {
      if (e.target.closest('.keyboard')) {
        e.preventDefault();
      }
    }, { passive: false });
  }
}
