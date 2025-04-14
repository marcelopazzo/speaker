import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "suggestion", "speakButton", "clearButton", "copySuggestion", "toggleButton"]

  connect() {
    this.typingTimer = null
    this.doneTypingInterval = 2000 // 2 seconds
    this.backspaceTimer = null
    this.initialDelay = 500
    this.repeatDelay = 100
    this.currentLayout = 'abc'
    this.setupKeyboard()
  }

  toggleLayout(event) {
    event.preventDefault()
    const layouts = {
      abc: { next: 'number', button: '123' },
      number: { next: 'qwerty', button: 'QWE' },
      qwerty: { next: 'abc', button: 'ABC' }
    }

    // Hide current keyboard
    document.getElementById(`${this.currentLayout}-keyboard`).classList.add('hidden')
    
    // Show next keyboard
    this.currentLayout = layouts[this.currentLayout].next
    document.getElementById(`${this.currentLayout}-keyboard`).classList.remove('hidden')

    // Update all toggle buttons
    this.toggleButtonTargets.forEach(button => {
      button.textContent = layouts[this.currentLayout].button
    })
  }

  setupKeyboard() {
    const textInput = this.inputTarget

    // Handle key presses
    const handleKeyPress = (key) => {
      const previousValue = textInput.value

      if (key === 'backspace') {
        textInput.value = textInput.value.slice(0, -1)
      } else if (key === 'enter') {
        textInput.value += '\n'
      } else {
        textInput.value += key
      }

      // Clear suggestion immediately when typing starts
      if (previousValue !== textInput.value) {
        this.suggestionTarget.textContent = ''
        this.input()
      }
    }

    // Add click handlers to all keys
    document.querySelectorAll('.key').forEach(key => {
      key.addEventListener('click', () => {
        const keyValue = key.getAttribute('data-key')
        handleKeyPress(keyValue)
      })

      // Backspace hold functionality
      if (key.getAttribute('data-key') === 'backspace') {
        key.addEventListener('mousedown', () => {
          handleKeyPress('backspace')
          this.backspaceTimer = setTimeout(() => {
            this.backspaceTimer = setInterval(() => {
              handleKeyPress('backspace')
            }, this.repeatDelay)
          }, this.initialDelay)
        })

        key.addEventListener('mouseup', () => {
          clearTimeout(this.backspaceTimer)
          clearInterval(this.backspaceTimer)
        })

        key.addEventListener('mouseleave', () => {
          clearTimeout(this.backspaceTimer)
          clearInterval(this.backspaceTimer)
        })
      }
    })
  }

  input() {
    const text = this.inputTarget.value

    // Clear the previous timer
    clearTimeout(this.typingTimer)

    // Only make request if we have at least 2 characters
    if (text.length >= 2) {
      // Set a new timer
      this.typingTimer = setTimeout(() => {
        this.fetchSuggestion(text)
      }, this.doneTypingInterval)
    } else {
      // Clear suggestion if text is too short
      this.suggestionTarget.textContent = ''
    }
  }

  fetchSuggestion(text) {
    fetch('/api/v1/smart_typer/suggest', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        text: text,
      })
    })
    .then(response => response.json())
    .then(data => {
      // Only show suggestion if confidence is above 0.2
      if (data.confidence >= 0.2) {
        let suggestionClass = 'suggestion-low'
        if (data.confidence >= 0.7) {
          suggestionClass = 'suggestion-high'
        } else if (data.confidence >= 0.2) {
          suggestionClass = 'suggestion-medium'
        }

        // Show only the suggested completion part
        const currentText = this.inputTarget.value
        const suggestionText = data.text.startsWith(currentText)
          ? data.text.slice(currentText.length)
          : data.text

        this.suggestionTarget.className = `suggestion ${suggestionClass}`
        this.suggestionTarget.textContent = suggestionText
      } else {
        this.suggestionTarget.textContent = ''
      }
    })
    .catch(error => console.error('Error:', error))
  }

  speakText() {
    const text = this.inputTarget.value
    if (!text) return

    fetch('/api/v1/text_reader/speak', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ text: text })
    })
    .then(response => {
      if (response.ok) {
        return response.blob()
      }
      throw new Error('Network response was not ok')
    })
    .then(blob => {
      const audioUrl = URL.createObjectURL(blob)
      const audio = new Audio(audioUrl)
      audio.play()
    })
    .catch(error => console.error('Error:', error))
  }

  clearText(event) {
    event.preventDefault()
    this.inputTarget.value = ''
    this.suggestionTarget.textContent = ''
    this.inputTarget.focus()
  }

  copySuggestion(event) {
    event.preventDefault()
    const currentText = this.inputTarget.value
    const suggestionText = this.suggestionTarget.textContent

    if (suggestionText) {
      this.inputTarget.value = suggestionText
      this.suggestionTarget.textContent = ''
      this.inputTarget.focus()
    }
  }
}
