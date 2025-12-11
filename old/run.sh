<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browser Hash Calculator</title>
    <!-- Load Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- 
        Removed external MD5 library (js-md5) 
        SHA-1 is natively supported by the Web Crypto API, making the app simpler and faster. 
    -->
    <style>
        /* Custom font */
        body {
            font-family: 'Inter', sans-serif;
            background-color: #f7f9fb;
        }
    </style>
</head>
<body class="min-h-screen flex items-center justify-center p-4">

    <div class="w-full max-w-xl bg-white shadow-2xl rounded-xl p-8 space-y-6 border border-gray-100">
        <h1 class="text-3xl font-extrabold text-gray-900 text-center border-b pb-3 mb-4">
            Universal Hash Calculator
        </h1>
        <p class="text-sm text-gray-500 text-center">
            This calculation is performed locally in your browser and is instant. The input string is never sent to a server.
        </p>

        <!-- Algorithm Selection -->
        <div>
            <label for="hashAlgorithm" class="block text-sm font-medium text-gray-700 mb-2">Select Hash Algorithm</label>
            <select 
                id="hashAlgorithm"
                class="w-full p-3 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500 transition duration-150"
            >
                <!-- Changed value from MD5 to SHA-1 -->
                <option value="SHA-256">SHA-256 (Recommended)</option>
                <option value="SHA-1">SHA-1 (Legacy)</option>
            </select>
        </div>

        <!-- Input Area -->
        <div>
            <label for="inputString" class="block text-sm font-medium text-gray-700 mb-2">Input Text to Hash</label>
            <textarea 
                id="inputString" 
                rows="4" 
                placeholder="Enter any text here..."
                class="w-full p-3 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500 transition duration-150 resize-none"
            ></textarea>
        </div>

        <!-- Calculate Button -->
        <button 
            id="hashButton"
            class="w-full flex justify-center py-3 px-4 border border-transparent rounded-lg shadow-md text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition duration-150 transform hover:scale-[1.01] active:scale-[0.99]"
        >
            Calculate Hash
        </button>

        <!-- Output Area -->
        <div id="outputContainer" class="hidden space-y-4">
            <div class="space-y-2">
                <label class="block text-sm font-medium text-gray-700">Hash Result (<span id="algorithmName">SHA-256</span>)</label>
                <div 
                    id="hashOutput" 
                    class="break-all bg-gray-50 text-gray-800 p-3 rounded-lg border border-gray-200 text-sm font-mono overflow-auto max-h-32"
                >
                    <!-- Hash will appear here -->
                </div>
            </div>

            <!-- Copy Button -->
            <button 
                id="copyButton" 
                class="w-full py-2 px-4 border border-blue-600 rounded-lg shadow-sm text-sm font-medium text-blue-600 bg-white hover:bg-blue-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition duration-150"
            >
                Copy to Clipboard
            </button>
        </div>
        
        <!-- Error/Message Box -->
        <div id="messageBox" class="text-sm p-3 rounded-lg hidden" role="alert"></div>

    </div>

    <script>
        // DOM Elements
        const inputString = document.getElementById('inputString');
        const hashButton = document.getElementById('hashButton');
        const outputContainer = document.getElementById('outputContainer');
        const hashOutput = document.getElementById('hashOutput');
        const copyButton = document.getElementById('copyButton');
        const messageBox = document.getElementById('messageBox');
        const hashAlgorithmSelect = document.getElementById('hashAlgorithm');
        const algorithmNameSpan = document.getElementById('algorithmName');

        // Helper function to show temporary messages
        function showMessage(text, type = 'info') {
            messageBox.textContent = text;
            // Removed specific color classes before adding new ones
            messageBox.className = 'text-sm p-3 rounded-lg'; 
            
            if (type === 'error') {
                messageBox.classList.add('bg-red-100', 'text-red-700');
            } else if (type === 'success') {
                messageBox.classList.add('bg-green-100', 'text-green-700');
            } else { // info
                messageBox.classList.add('bg-yellow-100', 'text-yellow-700');
            }

            setTimeout(() => {
                messageBox.classList.add('hidden');
            }, 3000);
        }

        // Converts an ArrayBuffer to a hexadecimal string
        function bufferToHex(buffer) {
            return Array.from(new Uint8Array(buffer))
                .map(b => b.toString(16).padStart(2, '0'))
                .join('');
        }

        /**
         * Core Hashing Function - uses the native Web Crypto API for both SHA-256 and SHA-1
         * @param {string} text - The input string
         * @param {string} algorithm - The hashing algorithm ('SHA-256' or 'SHA-1')
         * @returns {Promise<string|null>} The hex hash string or null on error
         */
        async function calculateHash(text, algorithm) {
            try {
                // Use native Web Crypto API for both SHA-256 and SHA-1
                const encoder = new TextEncoder();
                const data = encoder.encode(text);
                
                // The algorithm string for native crypto is "SHA-256" or "SHA-1"
                const hashBuffer = await crypto.subtle.digest(algorithm, data);
                
                return bufferToHex(hashBuffer);
                
            } catch (error) {
                console.error(`Hashing failed for ${algorithm}:`, error);
                showMessage(`An error occurred during ${algorithm} hashing.`, 'error');
                return null;
            }
        }

        // Event listener for the Calculate button
        hashButton.addEventListener('click', async () => {
            const text = inputString.value;
            const algorithm = hashAlgorithmSelect.value;
            
            if (!text) {
                showMessage("Please enter some text to hash.", 'info');
                return;
            }
            
            // UI state change
            hashButton.textContent = `Calculating ${algorithm}...`;
            hashButton.disabled = true;
            hashOutput.textContent = '...';

            const hash = await calculateHash(text, algorithm);

            if (hash) {
                hashOutput.textContent = hash;
                algorithmNameSpan.textContent = algorithm;
                outputContainer.classList.remove('hidden');
                showMessage(`${algorithm} hash calculated successfully!`, 'success');
            } else {
                hashOutput.textContent = "Error calculating hash.";
            }

            // UI state reset
            hashButton.textContent = "Calculate Hash";
            hashButton.disabled = false;
        });

        // Event listener for algorithm change to update output label
        hashAlgorithmSelect.addEventListener('change', () => {
             algorithmNameSpan.textContent = hashAlgorithmSelect.value;
             outputContainer.classList.add('hidden'); // Clear old result on change
        });

        // Event listener for the Copy button (using fallback for clipboard access)
        copyButton.addEventListener('click', () => {
            if (hashOutput.textContent && hashOutput.textContent !== "Error calculating hash." && hashOutput.textContent !== '...') {
                // Fallback method for copying text
                const range = document.createRange();
                range.selectNodeContents(hashOutput);
                const selection = window.getSelection();
                selection.removeAllRanges();
                selection.addRange(range);
                
                try {
                    document.execCommand('copy');
                    selection.removeAllRanges();
                    showMessage("Hash copied to clipboard!", 'success');
                } catch (err) {
                    showMessage("Could not copy text. Please copy manually.", 'error');
                }
            } else {
                showMessage("Nothing to copy.", 'info');
            }
        });

    </script>
</body>
</html>