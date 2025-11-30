# JavaScript Interview Questions & Coding Tests

## Table of Contents
1. [JavaScript Interview Questions (200)](#javascript-interview-questions)
2. [Coding Testing Questions (100)](#coding-testing-questions)
3. [Code Output Analysis Questions](#code-output-analysis-questions)

---

## JavaScript Interview Questions

### Fundamentals (1-40)

1. **What is JavaScript?**
   - JavaScript is a high-level, interpreted programming language that is widely used for web development.

2. **What are the different data types in JavaScript?**
   - Primitive: Number, String, Boolean, Undefined, Null, Symbol, BigInt
   - Non-primitive: Object (including Arrays, Functions)

3. **What is the difference between `var`, `let`, and `const`?**
   - `var`: Function-scoped, hoisted, can be redeclared
   - `let`: Block-scoped, hoisted but not initialized, cannot be redeclared
   - `const`: Block-scoped, must be initialized, cannot be reassigned

4. **What is hoisting in JavaScript?**
   - Hoisting is JavaScript's behavior of moving declarations to the top of their scope during compilation.

5. **What is a closure in JavaScript?**
   - A closure is a function that has access to variables in its outer (enclosing) scope even after the outer function has returned.

6. **What is the difference between `==` and `===`?**
   - `==` performs type coercion before comparison
   - `===` performs strict comparison without type coercion

7. **What is the `this` keyword in JavaScript?**
   - `this` refers to the object that is executing the current function.

8. **What are arrow functions and how do they differ from regular functions?**
   - Arrow functions have lexical `this` binding and cannot be used as constructors.

9. **What is the difference between `null` and `undefined`?**
   - `undefined`: variable declared but not assigned
   - `null`: intentional absence of value

10. **What is a callback function?**
    - A function passed as an argument to another function to be executed later.

11. **What is the event loop in JavaScript?**
    - The event loop handles asynchronous operations by managing the call stack and callback queue.

12. **What are promises in JavaScript?**
    - Promises represent the eventual completion or failure of an asynchronous operation.

13. **What is async/await?**
    - Syntactic sugar for working with promises in a more synchronous-looking way.

14. **What is prototypal inheritance?**
    - JavaScript's inheritance model where objects can inherit properties from other objects.

15. **What is the difference between `call`, `apply`, and `bind`?**
    - All three methods set the `this` context, but differ in how arguments are passed.

16. **What are template literals?**
    - String literals that allow embedded expressions using backticks and `${}` syntax.

17. **What is destructuring in JavaScript?**
    - Syntax for extracting values from arrays or properties from objects.

18. **What are default parameters?**
    - Function parameters that have default values when no argument is provided.

19. **What is the spread operator?**
    - Syntax (`...`) that allows expansion of iterables or objects.

20. **What is the rest parameter?**
    - Syntax that allows a function to accept indefinite number of arguments as an array.

21. **What are modules in JavaScript?**
    - Reusable pieces of code that can be exported and imported between files.

22. **What is the difference between synchronous and asynchronous programming?**
    - Synchronous: code executes line by line, blocking
    - Asynchronous: code can execute without blocking other operations

23. **What is JSON and how do you work with it?**
    - JavaScript Object Notation, parsed with `JSON.parse()` and stringified with `JSON.stringify()`.

24. **What are higher-order functions?**
    - Functions that take other functions as arguments or return functions.

25. **What is currying in JavaScript?**
    - Technique of transforming a function with multiple arguments into a sequence of functions.

26. **What is memoization?**
    - Optimization technique that stores results of expensive function calls.

27. **What are generators in JavaScript?**
    - Functions that can be paused and resumed, yielding multiple values over time.

28. **What is the `typeof` operator?**
    - Operator that returns a string indicating the type of the operand.

29. **What is the `instanceof` operator?**
    - Operator that tests whether an object has a specific constructor's prototype in its chain.

30. **What are symbols in JavaScript?**
    - Primitive data type that creates unique identifiers for object properties.

31. **What is the difference between `for...in` and `for...of`?**
    - `for...in`: iterates over enumerable properties
    - `for...of`: iterates over iterable values

32. **What is strict mode in JavaScript?**
    - A way to opt into a restricted variant of JavaScript with stricter error checking.

33. **What are immediately invoked function expressions (IIFE)?**
    - Functions that are executed immediately after they are defined.

34. **What is the difference between deep and shallow copy?**
    - Shallow copy: copies only the first level
    - Deep copy: copies all levels recursively

35. **What are WeakMap and WeakSet?**
    - Collections that hold weak references to their keys/values, allowing garbage collection.

36. **What is the difference between `setTimeout` and `setInterval`?**
    - `setTimeout`: executes once after delay
    - `setInterval`: executes repeatedly at intervals

37. **What are regular expressions in JavaScript?**
    - Patterns used to match character combinations in strings.

38. **What is the `arguments` object?**
    - Array-like object containing all arguments passed to a function.

39. **What is the difference between `slice` and `splice`?**
    - `slice`: returns new array without modifying original
    - `splice`: modifies original array

40. **What are getters and setters?**
    - Special methods that allow you to define how properties are accessed and modified.

### ES6+ Features (41-80)

41. **What are classes in JavaScript?**
    - Syntactic sugar over prototypal inheritance providing cleaner syntax for creating objects.

42. **What is the `Map` object?**
    - Collection that holds key-value pairs where keys can be any type.

43. **What is the `Set` object?**
    - Collection of unique values of any type.

44. **What are tagged template literals?**
    - Template literals preceded by a function that processes the template.

45. **What is the `Proxy` object?**
    - Allows you to intercept and customize operations on objects.

46. **What is the `Reflect` API?**
    - Provides methods for interceptable JavaScript operations.

47. **What are computed property names?**
    - Syntax that allows dynamic property names in object literals.

48. **What is object shorthand syntax?**
    - Concise way to define object properties and methods.

49. **What are static methods in classes?**
    - Methods that belong to the class itself rather than instances.

50. **What is the `super` keyword?**
    - Keyword used to access parent class properties and methods.

51. **What are private fields in classes?**
    - Class fields that are only accessible within the class using `#` syntax.

52. **What is optional chaining (`?.`)?**
    - Operator that allows safe property access on potentially null/undefined objects.

53. **What is nullish coalescing (`??`)?**
    - Operator that returns right operand when left is null or undefined.

54. **What are dynamic imports?**
    - Feature that allows importing modules asynchronously at runtime.

55. **What is `BigInt`?**
    - Primitive type for representing integers larger than `Number.MAX_SAFE_INTEGER`.

56. **What are `for await...of` loops?**
    - Loops for iterating over async iterables.

57. **What is `Promise.allSettled()`?**
    - Method that waits for all promises to settle regardless of outcome.

58. **What is `Promise.any()`?**
    - Method that resolves with the first fulfilled promise.

59. **What are top-level await?**
    - Feature allowing await at the module level without wrapping in async function.

60. **What is the `??=` operator?**
    - Nullish coalescing assignment operator.

61. **What are logical assignment operators?**
    - `&&=`, `||=`, `??=` operators that combine logical operations with assignment.

62. **What is `String.prototype.replaceAll()`?**
    - Method that replaces all occurrences of a substring.

63. **What are numeric separators?**
    - Underscores in numeric literals for better readability.

64. **What is `Array.prototype.at()`?**
    - Method that returns element at specified index, supporting negative indices.

65. **What are private methods in classes?**
    - Methods accessible only within the class using `#` syntax.

66. **What is the `Object.hasOwn()` method?**
    - Safer alternative to `Object.prototype.hasOwnProperty()`.

67. **What are error causes?**
    - Feature allowing chaining of error information.

68. **What is `Array.prototype.findLast()`?**
    - Method that returns the last element matching a condition.

69. **What is `Array.prototype.findLastIndex()`?**
    - Method that returns the index of the last element matching a condition.

70. **What are `Array.prototype.toReversed()` and similar methods?**
    - Non-mutating array methods that return new arrays.

71. **What is the `structuredClone()` function?**
    - Global function for deep cloning objects.

72. **What are decorators in JavaScript?**
    - Proposed feature for adding metadata and modifying classes and methods.

73. **What is the pipeline operator?**
    - Proposed operator for chaining function calls.

74. **What are records and tuples?**
    - Proposed immutable data structures.

75. **What is pattern matching?**
    - Proposed feature for matching values against patterns.

76. **What are temporal objects?**
    - Proposed API for better date and time handling.

77. **What is the `import.meta` object?**
    - Object containing metadata about the current module.

78. **What are import assertions?**
    - Feature for specifying the expected type of imported modules.

79. **What is the `Array.fromAsync()` method?**
    - Proposed method for creating arrays from async iterables.

80. **What are observable objects?**
    - Proposed feature for reactive programming patterns.

### DOM & Browser APIs (81-120)

81. **What is the DOM?**
    - Document Object Model, a programming interface for HTML documents.

82. **What is the difference between `innerHTML`, `textContent`, and `innerText`?**
    - Different ways to get/set content of elements with varying behavior.

83. **What are event listeners?**
    - Functions that handle events triggered by user interactions or system events.

84. **What is event bubbling and capturing?**
    - Two phases of event propagation in the DOM.

85. **What is event delegation?**
    - Technique of using a single event listener to handle events for multiple elements.

86. **What is the `localStorage` and `sessionStorage`?**
    - Web storage APIs for storing data in the browser.

87. **What are cookies?**
    - Small pieces of data stored by the browser and sent with HTTP requests.

88. **What is the Fetch API?**
    - Modern API for making HTTP requests.

89. **What is CORS?**
    - Cross-Origin Resource Sharing, a security feature implemented by browsers.

90. **What is the same-origin policy?**
    - Security concept that restricts how documents from one origin can interact with resources from another.

91. **What are Web Workers?**
    - Scripts that run in background threads separate from the main thread.

92. **What is the Intersection Observer API?**
    - API for observing changes in intersection of elements with viewport.

93. **What is the Mutation Observer API?**
    - API for observing changes to the DOM tree.

94. **What is the Resize Observer API?**
    - API for observing changes to element dimensions.

95. **What is the Performance API?**
    - API for measuring web page performance.

96. **What is the Geolocation API?**
    - API for accessing user's geographical location.

97. **What is the File API?**
    - API for working with files selected by the user.

98. **What is the Canvas API?**
    - API for drawing graphics programmatically.

99. **What is the Web Audio API?**
    - API for processing and synthesizing audio.

100. **What is the WebRTC API?**
     - API for real-time communication between browsers.

101. **What is the Service Worker API?**
     - API for creating background scripts that act as proxy between app and network.

102. **What is the Push API?**
     - API for receiving push messages from a server.

103. **What is the Notification API?**
     - API for displaying notifications to the user.

104. **What is the Vibration API?**
     - API for accessing device vibration hardware.

105. **What is the Battery Status API?**
     - API for accessing information about the system's battery.

106. **What is the Device Orientation API?**
     - API for accessing device orientation information.

107. **What is the Fullscreen API?**
     - API for programmatically entering and exiting fullscreen mode.

108. **What is the Page Visibility API?**
     - API for determining when a page is visible or hidden.

109. **What is the History API?**
     - API for manipulating browser history.

110. **What is the URL API?**
     - API for parsing and manipulating URLs.

111. **What is the Clipboard API?**
     - API for reading from and writing to the clipboard.

112. **What is the Web Share API?**
     - API for sharing content using the device's native sharing mechanism.

113. **What is the Payment Request API?**
     - API for handling payments on the web.

114. **What is the Web Bluetooth API?**
     - API for communicating with Bluetooth devices.

115. **What is the Web USB API?**
     - API for accessing USB devices from web pages.

116. **What is the WebGL API?**
     - API for rendering 3D graphics in the browser.

117. **What is the WebXR API?**
     - API for creating virtual and augmented reality experiences.

118. **What is the Broadcast Channel API?**
     - API for communication between browsing contexts.

119. **What is the Channel Messaging API?**
     - API for two-way communication between different execution contexts.

120. **What is the Streams API?**
     - API for processing streams of data.

### Advanced Concepts (121-160)

121. **What is functional programming in JavaScript?**
     - Programming paradigm that treats computation as evaluation of mathematical functions.

122. **What is object-oriented programming in JavaScript?**
     - Programming paradigm based on objects containing data and methods.

123. **What are design patterns in JavaScript?**
     - Reusable solutions to commonly occurring problems in software design.

124. **What is the Module pattern?**
     - Design pattern that provides encapsulation and privacy.

125. **What is the Observer pattern?**
     - Pattern where objects maintain a list of dependents and notify them of changes.

126. **What is the Singleton pattern?**
     - Pattern that ensures a class has only one instance.

127. **What is the Factory pattern?**
     - Pattern for creating objects without specifying their exact class.

128. **What is the Decorator pattern?**
     - Pattern for adding new functionality to objects dynamically.

129. **What is the Strategy pattern?**
     - Pattern that defines a family of algorithms and makes them interchangeable.

130. **What is the Command pattern?**
     - Pattern that encapsulates requests as objects.

131. **What is debouncing?**
     - Technique to limit the rate at which a function can fire.

132. **What is throttling?**
     - Technique to ensure a function is called at most once in a specified time period.

133. **What is lazy loading?**
     - Technique of deferring loading of resources until they're needed.

134. **What is code splitting?**
     - Technique of splitting code into smaller chunks for better performance.

135. **What is tree shaking?**
     - Process of removing unused code from bundles.

136. **What is polyfilling?**
     - Technique of providing modern functionality to older browsers.

137. **What is transpilation?**
     - Process of converting code from one language version to another.

138. **What is minification?**
     - Process of removing unnecessary characters from code to reduce size.

139. **What is bundling?**
     - Process of combining multiple files into a single file.

140. **What is the critical rendering path?**
     - Sequence of steps browsers take to render a page.

141. **What is progressive enhancement?**
     - Strategy of building web pages that work for everyone, then enhancing for capable browsers.

142. **What is graceful degradation?**
     - Strategy of building for modern browsers then ensuring basic functionality for older ones.

143. **What is accessibility in web development?**
     - Practice of making web content usable by people with disabilities.

144. **What is semantic HTML?**
     - Use of HTML markup to convey meaning rather than just presentation.

145. **What is responsive design?**
     - Approach to web design that makes pages render well on various devices.

146. **What is mobile-first design?**
     - Design approach that starts with mobile devices then scales up.

147. **What is progressive web app (PWA)?**
     - Web applications that use modern web capabilities to provide app-like experience.

148. **What is server-side rendering (SSR)?**
     - Technique of rendering web pages on the server before sending to client.

149. **What is client-side rendering (CSR)?**
     - Technique of rendering web pages in the browser using JavaScript.

150. **What is static site generation (SSG)?**
     - Method of pre-building web pages at build time.

151. **What is hydration?**
     - Process of attaching event listeners to server-rendered HTML.

152. **What is the JAMstack?**
     - Architecture based on JavaScript, APIs, and Markup.

153. **What is microservices architecture?**
     - Architectural style that structures applications as collection of loosely coupled services.

154. **What is serverless computing?**
     - Cloud computing model where cloud provider manages server infrastructure.

155. **What is edge computing?**
     - Computing paradigm that brings computation closer to data sources.

156. **What is content delivery network (CDN)?**
     - Distributed network of servers that deliver web content based on geographic location.

157. **What is caching?**
     - Technique of storing frequently accessed data for faster retrieval.

158. **What is load balancing?**
     - Method of distributing network traffic across multiple servers.

159. **What is database sharding?**
     - Method of horizontally partitioning data across multiple databases.

160. **What is API rate limiting?**
     - Technique of controlling the rate of requests to an API.

### Performance & Optimization (161-200)

161. **What is performance optimization?**
     - Process of improving the speed and efficiency of web applications.

162. **What are Core Web Vitals?**
     - Set of metrics that measure real-world user experience on web pages.

163. **What is Largest Contentful Paint (LCP)?**
     - Metric that measures loading performance.

164. **What is First Input Delay (FID)?**
     - Metric that measures interactivity.

165. **What is Cumulative Layout Shift (CLS)?**
     - Metric that measures visual stability.

166. **What is Time to First Byte (TTFB)?**
     - Metric that measures server response time.

167. **What is First Contentful Paint (FCP)?**
     - Metric that measures when first content appears.

168. **What is Time to Interactive (TTI)?**
     - Metric that measures when page becomes fully interactive.

169. **What is the performance budget?**
     - Limit set on metrics that affect site performance.

170. **What is resource prioritization?**
     - Technique of loading critical resources first.

171. **What is preloading?**
     - Technique of loading resources before they're needed.

172. **What is prefetching?**
     - Technique of loading resources that might be needed later.

173. **What is preconnecting?**
     - Technique of establishing connections before they're needed.

174. **What is DNS prefetching?**
     - Technique of resolving domain names before they're needed.

175. **What is image optimization?**
     - Process of reducing image file sizes without losing quality.

176. **What is WebP format?**
     - Modern image format that provides better compression.

177. **What is AVIF format?**
     - Next-generation image format with superior compression.

178. **What is responsive images?**
     - Technique of serving different images based on device capabilities.

179. **What is lazy loading images?**
     - Technique of loading images only when they're about to be viewed.

180. **What is font optimization?**
     - Process of optimizing web fonts for better performance.

181. **What is font display swap?**
     - CSS property that controls font loading behavior.

182. **What is critical CSS?**
     - CSS required to render above-the-fold content.

183. **What is CSS containment?**
     - CSS property that isolates parts of the page for better performance.

184. **What is will-change property?**
     - CSS property that hints to browser about upcoming changes.

185. **What is GPU acceleration?**
     - Technique of using graphics processor for rendering.

186. **What is the main thread?**
     - Primary thread where JavaScript execution and rendering happen.

187. **What is blocking vs non-blocking code?**
     - Code that prevents vs allows other operations to continue.

188. **What is the 60fps target?**
     - Goal of maintaining 60 frames per second for smooth animations.

189. **What is jank?**
     - Stuttering or lag in animations and interactions.

190. **What is the RAIL performance model?**
     - User-centric performance model: Response, Animation, Idle, Load.

191. **What is bundle analysis?**
     - Process of analyzing JavaScript bundles to identify optimization opportunities.

192. **What is dead code elimination?**
     - Process of removing unused code from bundles.

193. **What is compression?**
     - Technique of reducing file sizes for faster transfer.

194. **What is Gzip compression?**
     - Compression algorithm commonly used for web content.

195. **What is Brotli compression?**
     - Modern compression algorithm with better compression ratios.

196. **What is HTTP/2?**
     - Major revision of HTTP protocol with performance improvements.

197. **What is HTTP/3?**
     - Latest version of HTTP protocol using QUIC transport.

198. **What is service worker caching?**
     - Technique of caching resources using service workers.

199. **What is application shell architecture?**
     - Design approach that separates app shell from content.

200. **What is performance monitoring?**
     - Process of continuously measuring and tracking performance metrics.

---

## Coding Testing Questions

### Basic Level (1-30)

1. **Reverse a String**
```javascript
function reverseString(str) {
    return str.split('').reverse().join('');
}
// Test: reverseString("hello") → "olleh"
```

2. **Check if a Number is Prime**
```javascript
function isPrime(num) {
    if (num < 2) return false;
    for (let i = 2; i <= Math.sqrt(num); i++) {
        if (num % i === 0) return false;
    }
    return true;
}
// Test: isPrime(17) → true
```

3. **Find the Largest Number in Array**
```javascript
function findLargest(arr) {
    return Math.max(...arr);
}
// Test: findLargest([1, 5, 3, 9, 2]) → 9
```

4. **Remove Duplicates from Array**
```javascript
function removeDuplicates(arr) {
    return [...new Set(arr)];
}
// Test: removeDuplicates([1, 2, 2, 3, 4, 4, 5]) → [1, 2, 3, 4, 5]
```

5. **Count Vowels in a String**
```javascript
function countVowels(str) {
    return str.match(/[aeiouAEIOU]/g)?.length || 0;
}
// Test: countVowels("hello world") → 3
```6. **Fact
orial of a Number**
```javascript
function factorial(n) {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
}
// Test: factorial(5) → 120
```

7. **Check if String is Palindrome**
```javascript
function isPalindrome(str) {
    const cleaned = str.toLowerCase().replace(/[^a-z0-9]/g, '');
    return cleaned === cleaned.split('').reverse().join('');
}
// Test: isPalindrome("A man a plan a canal Panama") → true
```

8. **Sum of Array Elements**
```javascript
function sumArray(arr) {
    return arr.reduce((sum, num) => sum + num, 0);
}
// Test: sumArray([1, 2, 3, 4, 5]) → 15
```

9. **Find Missing Number in Array**
```javascript
function findMissing(arr, n) {
    const expectedSum = (n * (n + 1)) / 2;
    const actualSum = arr.reduce((sum, num) => sum + num, 0);
    return expectedSum - actualSum;
}
// Test: findMissing([1, 2, 4, 5], 5) → 3
```

10. **Capitalize First Letter of Each Word**
```javascript
function capitalizeWords(str) {
    return str.replace(/\b\w/g, char => char.toUpperCase());
}
// Test: capitalizeWords("hello world") → "Hello World"
```

11. **Check if Two Strings are Anagrams**
```javascript
function areAnagrams(str1, str2) {
    const normalize = str => str.toLowerCase().split('').sort().join('');
    return normalize(str1) === normalize(str2);
}
// Test: areAnagrams("listen", "silent") → true
```

12. **Find Second Largest Number**
```javascript
function secondLargest(arr) {
    const unique = [...new Set(arr)].sort((a, b) => b - a);
    return unique[1];
}
// Test: secondLargest([1, 3, 4, 5, 2]) → 4
```

13. **Fibonacci Sequence**
```javascript
function fibonacci(n) {
    if (n <= 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}
// Test: fibonacci(7) → 13
```

14. **Check if Array is Sorted**
```javascript
function isSorted(arr) {
    for (let i = 1; i < arr.length; i++) {
        if (arr[i] < arr[i - 1]) return false;
    }
    return true;
}
// Test: isSorted([1, 2, 3, 4, 5]) → true
```

15. **Count Character Frequency**
```javascript
function charFrequency(str) {
    const freq = {};
    for (let char of str) {
        freq[char] = (freq[char] || 0) + 1;
    }
    return freq;
}
// Test: charFrequency("hello") → {h: 1, e: 1, l: 2, o: 1}
```16. **Mer
ge Two Sorted Arrays**
```javascript
function mergeSorted(arr1, arr2) {
    let result = [];
    let i = 0, j = 0;
    
    while (i < arr1.length && j < arr2.length) {
        if (arr1[i] <= arr2[j]) {
            result.push(arr1[i++]);
        } else {
            result.push(arr2[j++]);
        }
    }
    
    return result.concat(arr1.slice(i)).concat(arr2.slice(j));
}
// Test: mergeSorted([1, 3, 5], [2, 4, 6]) → [1, 2, 3, 4, 5, 6]
```

17. **Find Common Elements in Arrays**
```javascript
function findCommon(arr1, arr2) {
    return arr1.filter(item => arr2.includes(item));
}
// Test: findCommon([1, 2, 3], [2, 3, 4]) → [2, 3]
```

18. **Rotate Array to Right**
```javascript
function rotateRight(arr, k) {
    k = k % arr.length;
    return arr.slice(-k).concat(arr.slice(0, -k));
}
// Test: rotateRight([1, 2, 3, 4, 5], 2) → [4, 5, 1, 2, 3]
```

19. **Check if Number is Perfect Square**
```javascript
function isPerfectSquare(num) {
    const sqrt = Math.sqrt(num);
    return sqrt === Math.floor(sqrt);
}
// Test: isPerfectSquare(16) → true
```

20. **Convert String to Title Case**
```javascript
function toTitleCase(str) {
    return str.toLowerCase().split(' ')
        .map(word => word.charAt(0).toUpperCase() + word.slice(1))
        .join(' ');
}
// Test: toTitleCase("hello world") → "Hello World"
```

21. **Find Longest Word in String**
```javascript
function longestWord(str) {
    return str.split(' ').reduce((longest, current) => 
        current.length > longest.length ? current : longest
    );
}
// Test: longestWord("The quick brown fox") → "quick"
```

22. **Calculate Power Without Math.pow**
```javascript
function power(base, exponent) {
    if (exponent === 0) return 1;
    if (exponent < 0) return 1 / power(base, -exponent);
    return base * power(base, exponent - 1);
}
// Test: power(2, 3) → 8
```

23. **Check if String Contains Only Digits**
```javascript
function isNumeric(str) {
    return /^\d+$/.test(str);
}
// Test: isNumeric("12345") → true
```

24. **Find Array Intersection**
```javascript
function intersection(arr1, arr2) {
    return arr1.filter(item => arr2.includes(item));
}
// Test: intersection([1, 2, 3], [2, 3, 4]) → [2, 3]
```

25. **Remove Falsy Values from Array**
```javascript
function removeFalsy(arr) {
    return arr.filter(Boolean);
}
// Test: removeFalsy([0, 1, false, 2, '', 3]) → [1, 2, 3]
```2
6. **Count Words in String**
```javascript
function countWords(str) {
    return str.trim().split(/\s+/).length;
}
// Test: countWords("Hello world from JavaScript") → 4
```

27. **Check if Array Contains Duplicate**
```javascript
function hasDuplicate(arr) {
    return new Set(arr).size !== arr.length;
}
// Test: hasDuplicate([1, 2, 3, 2]) → true
```

28. **Generate Random Number in Range**
```javascript
function randomInRange(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}
// Test: randomInRange(1, 10) → random number between 1-10
```

29. **Convert Celsius to Fahrenheit**
```javascript
function celsiusToFahrenheit(celsius) {
    return (celsius * 9/5) + 32;
}
// Test: celsiusToFahrenheit(0) → 32
```

30. **Find GCD of Two Numbers**
```javascript
function gcd(a, b) {
    return b === 0 ? a : gcd(b, a % b);
}
// Test: gcd(48, 18) → 6
```

### Intermediate Level (31-65)

31. **Implement Binary Search**
```javascript
function binarySearch(arr, target) {
    let left = 0, right = arr.length - 1;
    
    while (left <= right) {
        const mid = Math.floor((left + right) / 2);
        if (arr[mid] === target) return mid;
        if (arr[mid] < target) left = mid + 1;
        else right = mid - 1;
    }
    return -1;
}
// Test: binarySearch([1, 2, 3, 4, 5], 3) → 2
```

32. **Implement Quick Sort**
```javascript
function quickSort(arr) {
    if (arr.length <= 1) return arr;
    
    const pivot = arr[Math.floor(arr.length / 2)];
    const left = arr.filter(x => x < pivot);
    const middle = arr.filter(x => x === pivot);
    const right = arr.filter(x => x > pivot);
    
    return [...quickSort(left), ...middle, ...quickSort(right)];
}
// Test: quickSort([3, 6, 8, 10, 1, 2, 1]) → [1, 1, 2, 3, 6, 8, 10]
```

33. **Implement Merge Sort**
```javascript
function mergeSort(arr) {
    if (arr.length <= 1) return arr;
    
    const mid = Math.floor(arr.length / 2);
    const left = mergeSort(arr.slice(0, mid));
    const right = mergeSort(arr.slice(mid));
    
    return merge(left, right);
}

function merge(left, right) {
    let result = [];
    let i = 0, j = 0;
    
    while (i < left.length && j < right.length) {
        if (left[i] <= right[j]) {
            result.push(left[i++]);
        } else {
            result.push(right[j++]);
        }
    }
    
    return result.concat(left.slice(i)).concat(right.slice(j));
}
// Test: mergeSort([38, 27, 43, 3, 9, 82, 10]) → [3, 9, 10, 27, 38, 43, 82]
```

34. **Find Longest Substring Without Repeating Characters**
```javascript
function longestUniqueSubstring(s) {
    let maxLength = 0;
    let start = 0;
    const charMap = new Map();
    
    for (let end = 0; end < s.length; end++) {
        if (charMap.has(s[end])) {
            start = Math.max(charMap.get(s[end]) + 1, start);
        }
        charMap.set(s[end], end);
        maxLength = Math.max(maxLength, end - start + 1);
    }
    
    return maxLength;
}
// Test: longestUniqueSubstring("abcabcbb") → 3
```

35. **Implement Stack Class**
```javascript
class Stack {
    constructor() {
        this.items = [];
    }
    
    push(item) {
        this.items.push(item);
    }
    
    pop() {
        return this.items.pop();
    }
    
    peek() {
        return this.items[this.items.length - 1];
    }
    
    isEmpty() {
        return this.items.length === 0;
    }
    
    size() {
        return this.items.length;
    }
}
// Test: const stack = new Stack(); stack.push(1); stack.pop() → 1
```36. *
*Implement Queue Class**
```javascript
class Queue {
    constructor() {
        this.items = [];
    }
    
    enqueue(item) {
        this.items.push(item);
    }
    
    dequeue() {
        return this.items.shift();
    }
    
    front() {
        return this.items[0];
    }
    
    isEmpty() {
        return this.items.length === 0;
    }
    
    size() {
        return this.items.length;
    }
}
// Test: const queue = new Queue(); queue.enqueue(1); queue.dequeue() → 1
```

37. **Valid Parentheses Checker**
```javascript
function isValidParentheses(s) {
    const stack = [];
    const pairs = { '(': ')', '[': ']', '{': '}' };
    
    for (let char of s) {
        if (pairs[char]) {
            stack.push(char);
        } else if (Object.values(pairs).includes(char)) {
            if (!stack.length || pairs[stack.pop()] !== char) {
                return false;
            }
        }
    }
    
    return stack.length === 0;
}
// Test: isValidParentheses("()[]{}") → true
```

38. **Two Sum Problem**
```javascript
function twoSum(nums, target) {
    const map = new Map();
    
    for (let i = 0; i < nums.length; i++) {
        const complement = target - nums[i];
        if (map.has(complement)) {
            return [map.get(complement), i];
        }
        map.set(nums[i], i);
    }
    
    return [];
}
// Test: twoSum([2, 7, 11, 15], 9) → [0, 1]
```

39. **Implement LinkedList**
```javascript
class ListNode {
    constructor(val) {
        this.val = val;
        this.next = null;
    }
}

class LinkedList {
    constructor() {
        this.head = null;
    }
    
    append(val) {
        const newNode = new ListNode(val);
        if (!this.head) {
            this.head = newNode;
            return;
        }
        
        let current = this.head;
        while (current.next) {
            current = current.next;
        }
        current.next = newNode;
    }
    
    prepend(val) {
        const newNode = new ListNode(val);
        newNode.next = this.head;
        this.head = newNode;
    }
    
    delete(val) {
        if (!this.head) return;
        
        if (this.head.val === val) {
            this.head = this.head.next;
            return;
        }
        
        let current = this.head;
        while (current.next && current.next.val !== val) {
            current = current.next;
        }
        
        if (current.next) {
            current.next = current.next.next;
        }
    }
}
```

40. **Find Intersection of Two Arrays**
```javascript
function intersect(nums1, nums2) {
    const map = new Map();
    const result = [];
    
    for (let num of nums1) {
        map.set(num, (map.get(num) || 0) + 1);
    }
    
    for (let num of nums2) {
        if (map.get(num) > 0) {
            result.push(num);
            map.set(num, map.get(num) - 1);
        }
    }
    
    return result;
}
// Test: intersect([1,2,2,1], [2,2]) → [2,2]
```4
1. **Group Anagrams**
```javascript
function groupAnagrams(strs) {
    const map = new Map();
    
    for (let str of strs) {
        const key = str.split('').sort().join('');
        if (!map.has(key)) {
            map.set(key, []);
        }
        map.get(key).push(str);
    }
    
    return Array.from(map.values());
}
// Test: groupAnagrams(["eat","tea","tan","ate","nat","bat"]) → [["eat","tea","ate"],["tan","nat"],["bat"]]
```

42. **Longest Common Prefix**
```javascript
function longestCommonPrefix(strs) {
    if (!strs.length) return "";
    
    let prefix = strs[0];
    
    for (let i = 1; i < strs.length; i++) {
        while (strs[i].indexOf(prefix) !== 0) {
            prefix = prefix.substring(0, prefix.length - 1);
            if (!prefix) return "";
        }
    }
    
    return prefix;
}
// Test: longestCommonPrefix(["flower","flow","flight"]) → "fl"
```

43. **Maximum Subarray Sum (Kadane's Algorithm)**
```javascript
function maxSubArray(nums) {
    let maxSoFar = nums[0];
    let maxEndingHere = nums[0];
    
    for (let i = 1; i < nums.length; i++) {
        maxEndingHere = Math.max(nums[i], maxEndingHere + nums[i]);
        maxSoFar = Math.max(maxSoFar, maxEndingHere);
    }
    
    return maxSoFar;
}
// Test: maxSubArray([-2,1,-3,4,-1,2,1,-5,4]) → 6
```

44. **Rotate Matrix 90 Degrees**
```javascript
function rotate(matrix) {
    const n = matrix.length;
    
    // Transpose
    for (let i = 0; i < n; i++) {
        for (let j = i; j < n; j++) {
            [matrix[i][j], matrix[j][i]] = [matrix[j][i], matrix[i][j]];
        }
    }
    
    // Reverse each row
    for (let i = 0; i < n; i++) {
        matrix[i].reverse();
    }
    
    return matrix;
}
// Test: rotate([[1,2,3],[4,5,6],[7,8,9]]) → [[7,4,1],[8,5,2],[9,6,3]]
```

45. **Find Peak Element**
```javascript
function findPeakElement(nums) {
    let left = 0;
    let right = nums.length - 1;
    
    while (left < right) {
        const mid = Math.floor((left + right) / 2);
        if (nums[mid] > nums[mid + 1]) {
            right = mid;
        } else {
            left = mid + 1;
        }
    }
    
    return left;
}
// Test: findPeakElement([1,2,3,1]) → 2
```

46. **Implement Trie (Prefix Tree)**
```javascript
class TrieNode {
    constructor() {
        this.children = {};
        this.isEndOfWord = false;
    }
}

class Trie {
    constructor() {
        this.root = new TrieNode();
    }
    
    insert(word) {
        let node = this.root;
        for (let char of word) {
            if (!node.children[char]) {
                node.children[char] = new TrieNode();
            }
            node = node.children[char];
        }
        node.isEndOfWord = true;
    }
    
    search(word) {
        let node = this.root;
        for (let char of word) {
            if (!node.children[char]) {
                return false;
            }
            node = node.children[char];
        }
        return node.isEndOfWord;
    }
    
    startsWith(prefix) {
        let node = this.root;
        for (let char of prefix) {
            if (!node.children[char]) {
                return false;
            }
            node = node.children[char];
        }
        return true;
    }
}
```

47. **Product of Array Except Self**
```javascript
function productExceptSelf(nums) {
    const result = new Array(nums.length);
    
    // Left pass
    result[0] = 1;
    for (let i = 1; i < nums.length; i++) {
        result[i] = result[i - 1] * nums[i - 1];
    }
    
    // Right pass
    let right = 1;
    for (let i = nums.length - 1; i >= 0; i--) {
        result[i] *= right;
        right *= nums[i];
    }
    
    return result;
}
// Test: productExceptSelf([1,2,3,4]) → [24,12,8,6]
```48. **S
piral Matrix**
```javascript
function spiralOrder(matrix) {
    if (!matrix.length) return [];
    
    const result = [];
    let top = 0, bottom = matrix.length - 1;
    let left = 0, right = matrix[0].length - 1;
    
    while (top <= bottom && left <= right) {
        // Right
        for (let i = left; i <= right; i++) {
            result.push(matrix[top][i]);
        }
        top++;
        
        // Down
        for (let i = top; i <= bottom; i++) {
            result.push(matrix[i][right]);
        }
        right--;
        
        // Left
        if (top <= bottom) {
            for (let i = right; i >= left; i--) {
                result.push(matrix[bottom][i]);
            }
            bottom--;
        }
        
        // Up
        if (left <= right) {
            for (let i = bottom; i >= top; i--) {
                result.push(matrix[i][left]);
            }
            left++;
        }
    }
    
    return result;
}
// Test: spiralOrder([[1,2,3],[4,5,6],[7,8,9]]) → [1,2,3,6,9,8,7,4,5]
```

49. **Word Break Problem**
```javascript
function wordBreak(s, wordDict) {
    const wordSet = new Set(wordDict);
    const dp = new Array(s.length + 1).fill(false);
    dp[0] = true;
    
    for (let i = 1; i <= s.length; i++) {
        for (let j = 0; j < i; j++) {
            if (dp[j] && wordSet.has(s.substring(j, i))) {
                dp[i] = true;
                break;
            }
        }
    }
    
    return dp[s.length];
}
// Test: wordBreak("leetcode", ["leet","code"]) → true
```

50. **Coin Change Problem**
```javascript
function coinChange(coins, amount) {
    const dp = new Array(amount + 1).fill(Infinity);
    dp[0] = 0;
    
    for (let i = 1; i <= amount; i++) {
        for (let coin of coins) {
            if (coin <= i) {
                dp[i] = Math.min(dp[i], dp[i - coin] + 1);
            }
        }
    }
    
    return dp[amount] === Infinity ? -1 : dp[amount];
}
// Test: coinChange([1,3,4], 6) → 2
```

51. **House Robber Problem**
```javascript
function rob(nums) {
    if (!nums.length) return 0;
    if (nums.length === 1) return nums[0];
    
    let prev2 = nums[0];
    let prev1 = Math.max(nums[0], nums[1]);
    
    for (let i = 2; i < nums.length; i++) {
        const current = Math.max(prev1, prev2 + nums[i]);
        prev2 = prev1;
        prev1 = current;
    }
    
    return prev1;
}
// Test: rob([2,7,9,3,1]) → 12
```

52. **Climbing Stairs Problem**
```javascript
function climbStairs(n) {
    if (n <= 2) return n;
    
    let prev2 = 1;
    let prev1 = 2;
    
    for (let i = 3; i <= n; i++) {
        const current = prev1 + prev2;
        prev2 = prev1;
        prev1 = current;
    }
    
    return prev1;
}
// Test: climbStairs(5) → 8
```

53. **Unique Paths in Grid**
```javascript
function uniquePaths(m, n) {
    const dp = Array(m).fill().map(() => Array(n).fill(1));
    
    for (let i = 1; i < m; i++) {
        for (let j = 1; j < n; j++) {
            dp[i][j] = dp[i-1][j] + dp[i][j-1];
        }
    }
    
    return dp[m-1][n-1];
}
// Test: uniquePaths(3, 7) → 28
```

54. **Longest Increasing Subsequence**
```javascript
function lengthOfLIS(nums) {
    if (!nums.length) return 0;
    
    const dp = new Array(nums.length).fill(1);
    
    for (let i = 1; i < nums.length; i++) {
        for (let j = 0; j < i; j++) {
            if (nums[i] > nums[j]) {
                dp[i] = Math.max(dp[i], dp[j] + 1);
            }
        }
    }
    
    return Math.max(...dp);
}
// Test: lengthOfLIS([10,9,2,5,3,7,101,18]) → 4
```

55. **Container With Most Water**
```javascript
function maxArea(height) {
    let left = 0;
    let right = height.length - 1;
    let maxWater = 0;
    
    while (left < right) {
        const water = Math.min(height[left], height[right]) * (right - left);
        maxWater = Math.max(maxWater, water);
        
        if (height[left] < height[right]) {
            left++;
        } else {
            right--;
        }
    }
    
    return maxWater;
}
// Test: maxArea([1,8,6,2,5,4,8,3,7]) → 49
```5
6. **3Sum Problem**
```javascript
function threeSum(nums) {
    nums.sort((a, b) => a - b);
    const result = [];
    
    for (let i = 0; i < nums.length - 2; i++) {
        if (i > 0 && nums[i] === nums[i - 1]) continue;
        
        let left = i + 1;
        let right = nums.length - 1;
        
        while (left < right) {
            const sum = nums[i] + nums[left] + nums[right];
            
            if (sum === 0) {
                result.push([nums[i], nums[left], nums[right]]);
                
                while (left < right && nums[left] === nums[left + 1]) left++;
                while (left < right && nums[right] === nums[right - 1]) right--;
                
                left++;
                right--;
            } else if (sum < 0) {
                left++;
            } else {
                right--;
            }
        }
    }
    
    return result;
}
// Test: threeSum([-1,0,1,2,-1,-4]) → [[-1,-1,2],[-1,0,1]]
```

57. **Search in Rotated Sorted Array**
```javascript
function search(nums, target) {
    let left = 0;
    let right = nums.length - 1;
    
    while (left <= right) {
        const mid = Math.floor((left + right) / 2);
        
        if (nums[mid] === target) return mid;
        
        if (nums[left] <= nums[mid]) {
            if (nums[left] <= target && target < nums[mid]) {
                right = mid - 1;
            } else {
                left = mid + 1;
            }
        } else {
            if (nums[mid] < target && target <= nums[right]) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }
    }
    
    return -1;
}
// Test: search([4,5,6,7,0,1,2], 0) → 4
```

58. **Minimum Window Substring**
```javascript
function minWindow(s, t) {
    const need = new Map();
    const window = new Map();
    
    for (let char of t) {
        need.set(char, (need.get(char) || 0) + 1);
    }
    
    let left = 0, right = 0;
    let valid = 0;
    let start = 0, len = Infinity;
    
    while (right < s.length) {
        const c = s[right];
        right++;
        
        if (need.has(c)) {
            window.set(c, (window.get(c) || 0) + 1);
            if (window.get(c) === need.get(c)) {
                valid++;
            }
        }
        
        while (valid === need.size) {
            if (right - left < len) {
                start = left;
                len = right - left;
            }
            
            const d = s[left];
            left++;
            
            if (need.has(d)) {
                if (window.get(d) === need.get(d)) {
                    valid--;
                }
                window.set(d, window.get(d) - 1);
            }
        }
    }
    
    return len === Infinity ? "" : s.substr(start, len);
}
// Test: minWindow("ADOBECODEBANC", "ABC") → "BANC"
```

59. **Serialize and Deserialize Binary Tree**
```javascript
class TreeNode {
    constructor(val) {
        this.val = val;
        this.left = this.right = null;
    }
}

function serialize(root) {
    if (!root) return "null";
    return root.val + "," + serialize(root.left) + "," + serialize(root.right);
}

function deserialize(data) {
    const values = data.split(",");
    let index = 0;
    
    function buildTree() {
        if (values[index] === "null") {
            index++;
            return null;
        }
        
        const node = new TreeNode(parseInt(values[index]));
        index++;
        node.left = buildTree();
        node.right = buildTree();
        return node;
    }
    
    return buildTree();
}
```

60. **LRU Cache Implementation**
```javascript
class LRUCache {
    constructor(capacity) {
        this.capacity = capacity;
        this.cache = new Map();
    }
    
    get(key) {
        if (this.cache.has(key)) {
            const value = this.cache.get(key);
            this.cache.delete(key);
            this.cache.set(key, value);
            return value;
        }
        return -1;
    }
    
    put(key, value) {
        if (this.cache.has(key)) {
            this.cache.delete(key);
        } else if (this.cache.size >= this.capacity) {
            const firstKey = this.cache.keys().next().value;
            this.cache.delete(firstKey);
        }
        this.cache.set(key, value);
    }
}
```61. **M
edian of Two Sorted Arrays**
```javascript
function findMedianSortedArrays(nums1, nums2) {
    if (nums1.length > nums2.length) {
        [nums1, nums2] = [nums2, nums1];
    }
    
    const m = nums1.length;
    const n = nums2.length;
    let left = 0, right = m;
    
    while (left <= right) {
        const partitionX = Math.floor((left + right) / 2);
        const partitionY = Math.floor((m + n + 1) / 2) - partitionX;
        
        const maxLeftX = partitionX === 0 ? -Infinity : nums1[partitionX - 1];
        const minRightX = partitionX === m ? Infinity : nums1[partitionX];
        
        const maxLeftY = partitionY === 0 ? -Infinity : nums2[partitionY - 1];
        const minRightY = partitionY === n ? Infinity : nums2[partitionY];
        
        if (maxLeftX <= minRightY && maxLeftY <= minRightX) {
            if ((m + n) % 2 === 0) {
                return (Math.max(maxLeftX, maxLeftY) + Math.min(minRightX, minRightY)) / 2;
            } else {
                return Math.max(maxLeftX, maxLeftY);
            }
        } else if (maxLeftX > minRightY) {
            right = partitionX - 1;
        } else {
            left = partitionX + 1;
        }
    }
}
// Test: findMedianSortedArrays([1,3], [2]) → 2.0
```

62. **Regular Expression Matching**
```javascript
function isMatch(s, p) {
    const dp = Array(s.length + 1).fill().map(() => Array(p.length + 1).fill(false));
    dp[0][0] = true;
    
    for (let j = 1; j <= p.length; j++) {
        if (p[j - 1] === '*') {
            dp[0][j] = dp[0][j - 2];
        }
    }
    
    for (let i = 1; i <= s.length; i++) {
        for (let j = 1; j <= p.length; j++) {
            if (p[j - 1] === '*') {
                dp[i][j] = dp[i][j - 2] || 
                          (dp[i - 1][j] && (s[i - 1] === p[j - 2] || p[j - 2] === '.'));
            } else {
                dp[i][j] = dp[i - 1][j - 1] && (s[i - 1] === p[j - 1] || p[j - 1] === '.');
            }
        }
    }
    
    return dp[s.length][p.length];
}
// Test: isMatch("aa", "a*") → true
```

63. **Wildcard Pattern Matching**
```javascript
function isMatchWildcard(s, p) {
    const dp = Array(s.length + 1).fill().map(() => Array(p.length + 1).fill(false));
    dp[0][0] = true;
    
    for (let j = 1; j <= p.length; j++) {
        if (p[j - 1] === '*') {
            dp[0][j] = dp[0][j - 1];
        }
    }
    
    for (let i = 1; i <= s.length; i++) {
        for (let j = 1; j <= p.length; j++) {
            if (p[j - 1] === '*') {
                dp[i][j] = dp[i - 1][j] || dp[i][j - 1];
            } else if (p[j - 1] === '?' || s[i - 1] === p[j - 1]) {
                dp[i][j] = dp[i - 1][j - 1];
            }
        }
    }
    
    return dp[s.length][p.length];
}
// Test: isMatchWildcard("aa", "*") → true
```

64. **Edit Distance (Levenshtein Distance)**
```javascript
function minDistance(word1, word2) {
    const m = word1.length;
    const n = word2.length;
    const dp = Array(m + 1).fill().map(() => Array(n + 1).fill(0));
    
    for (let i = 0; i <= m; i++) dp[i][0] = i;
    for (let j = 0; j <= n; j++) dp[0][j] = j;
    
    for (let i = 1; i <= m; i++) {
        for (let j = 1; j <= n; j++) {
            if (word1[i - 1] === word2[j - 1]) {
                dp[i][j] = dp[i - 1][j - 1];
            } else {
                dp[i][j] = 1 + Math.min(
                    dp[i - 1][j],     // delete
                    dp[i][j - 1],     // insert
                    dp[i - 1][j - 1]  // replace
                );
            }
        }
    }
    
    return dp[m][n];
}
// Test: minDistance("horse", "ros") → 3
```

65. **Sliding Window Maximum**
```javascript
function maxSlidingWindow(nums, k) {
    const result = [];
    const deque = [];
    
    for (let i = 0; i < nums.length; i++) {
        while (deque.length && deque[0] < i - k + 1) {
            deque.shift();
        }
        
        while (deque.length && nums[deque[deque.length - 1]] < nums[i]) {
            deque.pop();
        }
        
        deque.push(i);
        
        if (i >= k - 1) {
            result.push(nums[deque[0]]);
        }
    }
    
    return result;
}
// Test: maxSlidingWindow([1,3,-1,-3,5,3,6,7], 3) → [3,3,5,5,6,7]
```### Ad
vanced Level (66-100)

66. **N-Queens Problem**
```javascript
function solveNQueens(n) {
    const result = [];
    const board = Array(n).fill().map(() => Array(n).fill('.'));
    
    function isValid(row, col) {
        for (let i = 0; i < row; i++) {
            if (board[i][col] === 'Q') return false;
        }
        
        for (let i = row - 1, j = col - 1; i >= 0 && j >= 0; i--, j--) {
            if (board[i][j] === 'Q') return false;
        }
        
        for (let i = row - 1, j = col + 1; i >= 0 && j < n; i--, j++) {
            if (board[i][j] === 'Q') return false;
        }
        
        return true;
    }
    
    function backtrack(row) {
        if (row === n) {
            result.push(board.map(row => row.join('')));
            return;
        }
        
        for (let col = 0; col < n; col++) {
            if (isValid(row, col)) {
                board[row][col] = 'Q';
                backtrack(row + 1);
                board[row][col] = '.';
            }
        }
    }
    
    backtrack(0);
    return result;
}
// Test: solveNQueens(4) → [[".Q..","...Q","Q...","..Q."],["..Q.","Q...","...Q",".Q.."]]
```

67. **Sudoku Solver**
```javascript
function solveSudoku(board) {
    function isValid(board, row, col, num) {
        for (let i = 0; i < 9; i++) {
            if (board[row][i] === num || board[i][col] === num) return false;
        }
        
        const startRow = Math.floor(row / 3) * 3;
        const startCol = Math.floor(col / 3) * 3;
        
        for (let i = startRow; i < startRow + 3; i++) {
            for (let j = startCol; j < startCol + 3; j++) {
                if (board[i][j] === num) return false;
            }
        }
        
        return true;
    }
    
    function solve(board) {
        for (let row = 0; row < 9; row++) {
            for (let col = 0; col < 9; col++) {
                if (board[row][col] === '.') {
                    for (let num = '1'; num <= '9'; num++) {
                        if (isValid(board, row, col, num)) {
                            board[row][col] = num;
                            if (solve(board)) return true;
                            board[row][col] = '.';
                        }
                    }
                    return false;
                }
            }
        }
        return true;
    }
    
    solve(board);
}
```

68. **Word Ladder**
```javascript
function ladderLength(beginWord, endWord, wordList) {
    const wordSet = new Set(wordList);
    if (!wordSet.has(endWord)) return 0;
    
    const queue = [[beginWord, 1]];
    const visited = new Set([beginWord]);
    
    while (queue.length) {
        const [word, level] = queue.shift();
        
        if (word === endWord) return level;
        
        for (let i = 0; i < word.length; i++) {
            for (let c = 97; c <= 122; c++) {
                const newWord = word.slice(0, i) + String.fromCharCode(c) + word.slice(i + 1);
                
                if (wordSet.has(newWord) && !visited.has(newWord)) {
                    visited.add(newWord);
                    queue.push([newWord, level + 1]);
                }
            }
        }
    }
    
    return 0;
}
// Test: ladderLength("hit", "cog", ["hot","dot","dog","lot","log","cog"]) → 5
```

69. **Alien Dictionary**
```javascript
function alienOrder(words) {
    const graph = new Map();
    const inDegree = new Map();
    
    // Initialize
    for (let word of words) {
        for (let char of word) {
            graph.set(char, new Set());
            inDegree.set(char, 0);
        }
    }
    
    // Build graph
    for (let i = 0; i < words.length - 1; i++) {
        const word1 = words[i];
        const word2 = words[i + 1];
        
        if (word1.length > word2.length && word1.startsWith(word2)) {
            return "";
        }
        
        for (let j = 0; j < Math.min(word1.length, word2.length); j++) {
            if (word1[j] !== word2[j]) {
                if (!graph.get(word1[j]).has(word2[j])) {
                    graph.get(word1[j]).add(word2[j]);
                    inDegree.set(word2[j], inDegree.get(word2[j]) + 1);
                }
                break;
            }
        }
    }
    
    // Topological sort
    const queue = [];
    for (let [char, degree] of inDegree) {
        if (degree === 0) queue.push(char);
    }
    
    let result = "";
    while (queue.length) {
        const char = queue.shift();
        result += char;
        
        for (let neighbor of graph.get(char)) {
            inDegree.set(neighbor, inDegree.get(neighbor) - 1);
            if (inDegree.get(neighbor) === 0) {
                queue.push(neighbor);
            }
        }
    }
    
    return result.length === inDegree.size ? result : "";
}
```

70. **Course Schedule II**
```javascript
function findOrder(numCourses, prerequisites) {
    const graph = Array(numCourses).fill().map(() => []);
    const inDegree = Array(numCourses).fill(0);
    
    for (let [course, prereq] of prerequisites) {
        graph[prereq].push(course);
        inDegree[course]++;
    }
    
    const queue = [];
    for (let i = 0; i < numCourses; i++) {
        if (inDegree[i] === 0) queue.push(i);
    }
    
    const result = [];
    while (queue.length) {
        const course = queue.shift();
        result.push(course);
        
        for (let nextCourse of graph[course]) {
            inDegree[nextCourse]--;
            if (inDegree[nextCourse] === 0) {
                queue.push(nextCourse);
            }
        }
    }
    
    return result.length === numCourses ? result : [];
}
// Test: findOrder(4, [[1,0],[2,0],[3,1],[3,2]]) → [0,1,2,3] or [0,2,1,3]
```71.
 **Minimum Spanning Tree (Kruskal's Algorithm)**
```javascript
class UnionFind {
    constructor(n) {
        this.parent = Array(n).fill().map((_, i) => i);
        this.rank = Array(n).fill(0);
    }
    
    find(x) {
        if (this.parent[x] !== x) {
            this.parent[x] = this.find(this.parent[x]);
        }
        return this.parent[x];
    }
    
    union(x, y) {
        const rootX = this.find(x);
        const rootY = this.find(y);
        
        if (rootX !== rootY) {
            if (this.rank[rootX] < this.rank[rootY]) {
                this.parent[rootX] = rootY;
            } else if (this.rank[rootX] > this.rank[rootY]) {
                this.parent[rootY] = rootX;
            } else {
                this.parent[rootY] = rootX;
                this.rank[rootX]++;
            }
            return true;
        }
        return false;
    }
}

function minCostConnectPoints(points) {
    const n = points.length;
    const edges = [];
    
    for (let i = 0; i < n; i++) {
        for (let j = i + 1; j < n; j++) {
            const dist = Math.abs(points[i][0] - points[j][0]) + 
                        Math.abs(points[i][1] - points[j][1]);
            edges.push([dist, i, j]);
        }
    }
    
    edges.sort((a, b) => a[0] - b[0]);
    
    const uf = new UnionFind(n);
    let cost = 0;
    let edgesUsed = 0;
    
    for (let [weight, u, v] of edges) {
        if (uf.union(u, v)) {
            cost += weight;
            edgesUsed++;
            if (edgesUsed === n - 1) break;
        }
    }
    
    return cost;
}
```

72. **Dijkstra's Shortest Path Algorithm**
```javascript
function dijkstra(graph, start) {
    const distances = {};
    const visited = new Set();
    const pq = [[0, start]];
    
    for (let node in graph) {
        distances[node] = Infinity;
    }
    distances[start] = 0;
    
    while (pq.length) {
        pq.sort((a, b) => a[0] - b[0]);
        const [currentDistance, currentNode] = pq.shift();
        
        if (visited.has(currentNode)) continue;
        visited.add(currentNode);
        
        for (let neighbor in graph[currentNode]) {
            const distance = currentDistance + graph[currentNode][neighbor];
            
            if (distance < distances[neighbor]) {
                distances[neighbor] = distance;
                pq.push([distance, neighbor]);
            }
        }
    }
    
    return distances;
}
```

73. **Bellman-Ford Algorithm**
```javascript
function bellmanFord(edges, V, src) {
    const dist = Array(V).fill(Infinity);
    dist[src] = 0;
    
    for (let i = 0; i < V - 1; i++) {
        for (let [u, v, w] of edges) {
            if (dist[u] !== Infinity && dist[u] + w < dist[v]) {
                dist[v] = dist[u] + w;
            }
        }
    }
    
    // Check for negative cycles
    for (let [u, v, w] of edges) {
        if (dist[u] !== Infinity && dist[u] + w < dist[v]) {
            return null; // Negative cycle detected
        }
    }
    
    return dist;
}
```

74. **Floyd-Warshall Algorithm**
```javascript
function floydWarshall(graph) {
    const V = graph.length;
    const dist = Array(V).fill().map(() => Array(V).fill(Infinity));
    
    // Initialize distances
    for (let i = 0; i < V; i++) {
        for (let j = 0; j < V; j++) {
            if (i === j) {
                dist[i][j] = 0;
            } else if (graph[i][j] !== 0) {
                dist[i][j] = graph[i][j];
            }
        }
    }
    
    // Floyd-Warshall algorithm
    for (let k = 0; k < V; k++) {
        for (let i = 0; i < V; i++) {
            for (let j = 0; j < V; j++) {
                if (dist[i][k] + dist[k][j] < dist[i][j]) {
                    dist[i][j] = dist[i][k] + dist[k][j];
                }
            }
        }
    }
    
    return dist;
}
```

75. **Topological Sort (DFS)**
```javascript
function topologicalSort(graph) {
    const visited = new Set();
    const stack = [];
    
    function dfs(node) {
        visited.add(node);
        
        for (let neighbor of graph[node] || []) {
            if (!visited.has(neighbor)) {
                dfs(neighbor);
            }
        }
        
        stack.push(node);
    }
    
    for (let node in graph) {
        if (!visited.has(node)) {
            dfs(node);
        }
    }
    
    return stack.reverse();
}
```

76. **Strongly Connected Components (Tarjan's Algorithm)**
```javascript
function tarjanSCC(graph) {
    let time = 0;
    const visited = new Set();
    const disc = {};
    const low = {};
    const stack = [];
    const inStack = new Set();
    const sccs = [];
    
    function dfs(u) {
        disc[u] = low[u] = ++time;
        visited.add(u);
        stack.push(u);
        inStack.add(u);
        
        for (let v of graph[u] || []) {
            if (!visited.has(v)) {
                dfs(v);
                low[u] = Math.min(low[u], low[v]);
            } else if (inStack.has(v)) {
                low[u] = Math.min(low[u], disc[v]);
            }
        }
        
        if (low[u] === disc[u]) {
            const scc = [];
            let w;
            do {
                w = stack.pop();
                inStack.delete(w);
                scc.push(w);
            } while (w !== u);
            sccs.push(scc);
        }
    }
    
    for (let node in graph) {
        if (!visited.has(node)) {
            dfs(node);
        }
    }
    
    return sccs;
}
```

77. **Maximum Flow (Ford-Fulkerson)**
```javascript
function maxFlow(capacity, source, sink) {
    const n = capacity.length;
    const flow = Array(n).fill().map(() => Array(n).fill(0));
    let maxFlowValue = 0;
    
    function bfs(source, sink, parent) {
        const visited = Array(n).fill(false);
        const queue = [source];
        visited[source] = true;
        
        while (queue.length) {
            const u = queue.shift();
            
            for (let v = 0; v < n; v++) {
                if (!visited[v] && capacity[u][v] - flow[u][v] > 0) {
                    visited[v] = true;
                    parent[v] = u;
                    if (v === sink) return true;
                    queue.push(v);
                }
            }
        }
        
        return false;
    }
    
    const parent = Array(n);
    
    while (bfs(source, sink, parent)) {
        let pathFlow = Infinity;
        
        for (let v = sink; v !== source; v = parent[v]) {
            const u = parent[v];
            pathFlow = Math.min(pathFlow, capacity[u][v] - flow[u][v]);
        }
        
        for (let v = sink; v !== source; v = parent[v]) {
            const u = parent[v];
            flow[u][v] += pathFlow;
            flow[v][u] -= pathFlow;
        }
        
        maxFlowValue += pathFlow;
    }
    
    return maxFlowValue;
}
```

78. **Segment Tree Implementation**
```javascript
class SegmentTree {
    constructor(arr) {
        this.n = arr.length;
        this.tree = Array(4 * this.n);
        this.build(arr, 0, 0, this.n - 1);
    }
    
    build(arr, node, start, end) {
        if (start === end) {
            this.tree[node] = arr[start];
        } else {
            const mid = Math.floor((start + end) / 2);
            this.build(arr, 2 * node + 1, start, mid);
            this.build(arr, 2 * node + 2, mid + 1, end);
            this.tree[node] = this.tree[2 * node + 1] + this.tree[2 * node + 2];
        }
    }
    
    update(node, start, end, idx, val) {
        if (start === end) {
            this.tree[node] = val;
        } else {
            const mid = Math.floor((start + end) / 2);
            if (idx <= mid) {
                this.update(2 * node + 1, start, mid, idx, val);
            } else {
                this.update(2 * node + 2, mid + 1, end, idx, val);
            }
            this.tree[node] = this.tree[2 * node + 1] + this.tree[2 * node + 2];
        }
    }
    
    query(node, start, end, l, r) {
        if (r < start || end < l) return 0;
        if (l <= start && end <= r) return this.tree[node];
        
        const mid = Math.floor((start + end) / 2);
        const p1 = this.query(2 * node + 1, start, mid, l, r);
        const p2 = this.query(2 * node + 2, mid + 1, end, l, r);
        return p1 + p2;
    }
    
    updateValue(idx, val) {
        this.update(0, 0, this.n - 1, idx, val);
    }
    
    rangeQuery(l, r) {
        return this.query(0, 0, this.n - 1, l, r);
    }
}
```

79. **Fenwick Tree (Binary Indexed Tree)**
```javascript
class FenwickTree {
    constructor(n) {
        this.n = n;
        this.tree = Array(n + 1).fill(0);
    }
    
    update(i, delta) {
        while (i <= this.n) {
            this.tree[i] += delta;
            i += i & (-i);
        }
    }
    
    query(i) {
        let sum = 0;
        while (i > 0) {
            sum += this.tree[i];
            i -= i & (-i);
        }
        return sum;
    }
    
    rangeQuery(l, r) {
        return this.query(r) - this.query(l - 1);
    }
}
```

80. **Manacher's Algorithm (Longest Palindromic Substring)**
```javascript
function longestPalindrome(s) {
    if (!s) return "";
    
    // Transform string
    let transformed = "#";
    for (let char of s) {
        transformed += char + "#";
    }
    
    const n = transformed.length;
    const P = Array(n).fill(0);
    let center = 0, right = 0;
    let maxLen = 0, centerIndex = 0;
    
    for (let i = 0; i < n; i++) {
        const mirror = 2 * center - i;
        
        if (i < right) {
            P[i] = Math.min(right - i, P[mirror]);
        }
        
        try {
            while (transformed[i + (1 + P[i])] === transformed[i - (1 + P[i])]) {
                P[i]++;
            }
        } catch (e) {}
        
        if (i + P[i] > right) {
            center = i;
            right = i + P[i];
        }
        
        if (P[i] > maxLen) {
            maxLen = P[i];
            centerIndex = i;
        }
    }
    
    const start = (centerIndex - maxLen) / 2;
    return s.substring(start, start + maxLen);
}
```81. *
*KMP String Matching Algorithm**
```javascript
function KMPSearch(text, pattern) {
    const lps = computeLPS(pattern);
    const result = [];
    let i = 0, j = 0;
    
    while (i < text.length) {
        if (pattern[j] === text[i]) {
            i++;
            j++;
        }
        
        if (j === pattern.length) {
            result.push(i - j);
            j = lps[j - 1];
        } else if (i < text.length && pattern[j] !== text[i]) {
            if (j !== 0) {
                j = lps[j - 1];
            } else {
                i++;
            }
        }
    }
    
    return result;
}

function computeLPS(pattern) {
    const lps = Array(pattern.length).fill(0);
    let len = 0;
    let i = 1;
    
    while (i < pattern.length) {
        if (pattern[i] === pattern[len]) {
            len++;
            lps[i] = len;
            i++;
        } else {
            if (len !== 0) {
                len = lps[len - 1];
            } else {
                lps[i] = 0;
                i++;
            }
        }
    }
    
    return lps;
}
```

82. **Rabin-Karp String Matching**
```javascript
function rabinKarp(text, pattern) {
    const d = 256; // Number of characters in alphabet
    const q = 101; // A prime number
    const m = pattern.length;
    const n = text.length;
    let p = 0; // Hash value for pattern
    let t = 0; // Hash value for text
    let h = 1;
    const result = [];
    
    // Calculate h = pow(d, m-1) % q
    for (let i = 0; i < m - 1; i++) {
        h = (h * d) % q;
    }
    
    // Calculate hash values for pattern and first window
    for (let i = 0; i < m; i++) {
        p = (d * p + pattern.charCodeAt(i)) % q;
        t = (d * t + text.charCodeAt(i)) % q;
    }
    
    // Slide pattern over text
    for (let i = 0; i <= n - m; i++) {
        if (p === t) {
            let match = true;
            for (let j = 0; j < m; j++) {
                if (text[i + j] !== pattern[j]) {
                    match = false;
                    break;
                }
            }
            if (match) result.push(i);
        }
        
        if (i < n - m) {
            t = (d * (t - text.charCodeAt(i) * h) + text.charCodeAt(i + m)) % q;
            if (t < 0) t += q;
        }
    }
    
    return result;
}
```

83. **Z Algorithm for Pattern Matching**
```javascript
function zAlgorithm(s) {
    const n = s.length;
    const z = Array(n).fill(0);
    let l = 0, r = 0;
    
    for (let i = 1; i < n; i++) {
        if (i <= r) {
            z[i] = Math.min(r - i + 1, z[i - l]);
        }
        
        while (i + z[i] < n && s[z[i]] === s[i + z[i]]) {
            z[i]++;
        }
        
        if (i + z[i] - 1 > r) {
            l = i;
            r = i + z[i] - 1;
        }
    }
    
    return z;
}

function patternSearch(text, pattern) {
    const combined = pattern + "$" + text;
    const z = zAlgorithm(combined);
    const result = [];
    
    for (let i = 0; i < z.length; i++) {
        if (z[i] === pattern.length) {
            result.push(i - pattern.length - 1);
        }
    }
    
    return result;
}
```

84. **Suffix Array Construction**
```javascript
function buildSuffixArray(s) {
    const n = s.length;
    const suffixes = [];
    
    for (let i = 0; i < n; i++) {
        suffixes.push([s.substring(i), i]);
    }
    
    suffixes.sort((a, b) => a[0].localeCompare(b[0]));
    
    return suffixes.map(suffix => suffix[1]);
}

function buildLCPArray(s, suffixArray) {
    const n = s.length;
    const lcp = Array(n - 1).fill(0);
    const rank = Array(n);
    
    for (let i = 0; i < n; i++) {
        rank[suffixArray[i]] = i;
    }
    
    let h = 0;
    for (let i = 0; i < n; i++) {
        if (rank[i] > 0) {
            const j = suffixArray[rank[i] - 1];
            while (i + h < n && j + h < n && s[i + h] === s[j + h]) {
                h++;
            }
            lcp[rank[i] - 1] = h;
            if (h > 0) h--;
        }
    }
    
    return lcp;
}
```

85. **Aho-Corasick Algorithm**
```javascript
class AhoCorasick {
    constructor() {
        this.trie = { children: {}, isEnd: false, patterns: [] };
        this.failure = new Map();
    }
    
    addPattern(pattern, id) {
        let node = this.trie;
        for (let char of pattern) {
            if (!node.children[char]) {
                node.children[char] = { children: {}, isEnd: false, patterns: [] };
            }
            node = node.children[char];
        }
        node.isEnd = true;
        node.patterns.push({ pattern, id });
    }
    
    buildFailureFunction() {
        const queue = [];
        this.failure.set(this.trie, null);
        
        for (let char in this.trie.children) {
            const child = this.trie.children[char];
            this.failure.set(child, this.trie);
            queue.push(child);
        }
        
        while (queue.length) {
            const node = queue.shift();
            
            for (let char in node.children) {
                const child = node.children[char];
                queue.push(child);
                
                let failure = this.failure.get(node);
                while (failure && !failure.children[char]) {
                    failure = this.failure.get(failure);
                }
                
                this.failure.set(child, failure ? failure.children[char] : this.trie);
                
                const failureNode = this.failure.get(child);
                child.patterns = child.patterns.concat(failureNode.patterns);
            }
        }
    }
    
    search(text) {
        this.buildFailureFunction();
        const matches = [];
        let node = this.trie;
        
        for (let i = 0; i < text.length; i++) {
            const char = text[i];
            
            while (node && !node.children[char]) {
                node = this.failure.get(node);
            }
            
            if (!node) {
                node = this.trie;
                continue;
            }
            
            node = node.children[char];
            
            for (let pattern of node.patterns) {
                matches.push({
                    pattern: pattern.pattern,
                    id: pattern.id,
                    position: i - pattern.pattern.length + 1
                });
            }
        }
        
        return matches;
    }
}
```

86. **Heavy-Light Decomposition**
```javascript
class HeavyLightDecomposition {
    constructor(tree, root = 0) {
        this.n = tree.length;
        this.tree = tree;
        this.parent = Array(this.n).fill(-1);
        this.depth = Array(this.n).fill(0);
        this.heavy = Array(this.n).fill(-1);
        this.head = Array(this.n);
        this.pos = Array(this.n);
        this.currentPos = 0;
        
        this.dfs(root);
        this.decompose(root, root);
    }
    
    dfs(v) {
        let size = 1;
        let maxChildSize = 0;
        
        for (let u of this.tree[v]) {
            if (u !== this.parent[v]) {
                this.parent[u] = v;
                this.depth[u] = this.depth[v] + 1;
                const childSize = this.dfs(u);
                size += childSize;
                
                if (childSize > maxChildSize) {
                    maxChildSize = childSize;
                    this.heavy[v] = u;
                }
            }
        }
        
        return size;
    }
    
    decompose(v, h) {
        this.head[v] = h;
        this.pos[v] = this.currentPos++;
        
        if (this.heavy[v] !== -1) {
            this.decompose(this.heavy[v], h);
        }
        
        for (let u of this.tree[v]) {
            if (u !== this.parent[v] && u !== this.heavy[v]) {
                this.decompose(u, u);
            }
        }
    }
    
    query(a, b) {
        let result = 0;
        
        while (this.head[a] !== this.head[b]) {
            if (this.depth[this.head[a]] > this.depth[this.head[b]]) {
                [a, b] = [b, a];
            }
            
            // Query from head[b] to b
            result += this.segmentTreeQuery(this.pos[this.head[b]], this.pos[b]);
            b = this.parent[this.head[b]];
        }
        
        if (this.depth[a] > this.depth[b]) {
            [a, b] = [b, a];
        }
        
        result += this.segmentTreeQuery(this.pos[a], this.pos[b]);
        return result;
    }
    
    segmentTreeQuery(l, r) {
        // Implement segment tree query
        return 0;
    }
}
```

87. **Centroid Decomposition**
```javascript
class CentroidDecomposition {
    constructor(tree) {
        this.tree = tree;
        this.n = tree.length;
        this.removed = Array(this.n).fill(false);
        this.subtreeSize = Array(this.n);
        this.centroidTree = Array(this.n).fill().map(() => []);
        
        this.decompose(0, -1);
    }
    
    getSubtreeSize(v, parent) {
        this.subtreeSize[v] = 1;
        for (let u of this.tree[v]) {
            if (u !== parent && !this.removed[u]) {
                this.subtreeSize[v] += this.getSubtreeSize(u, v);
            }
        }
        return this.subtreeSize[v];
    }
    
    getCentroid(v, parent, treeSize) {
        for (let u of this.tree[v]) {
            if (u !== parent && !this.removed[u] && 
                this.subtreeSize[u] > treeSize / 2) {
                return this.getCentroid(u, v, treeSize);
            }
        }
        return v;
    }
    
    decompose(v, parent) {
        const treeSize = this.getSubtreeSize(v, -1);
        const centroid = this.getCentroid(v, -1, treeSize);
        
        this.removed[centroid] = true;
        
        if (parent !== -1) {
            this.centroidTree[parent].push(centroid);
        }
        
        for (let u of this.tree[centroid]) {
            if (!this.removed[u]) {
                this.decompose(u, centroid);
            }
        }
    }
}
```

88. **Mo's Algorithm**
```javascript
class MoAlgorithm {
    constructor(arr, queries) {
        this.arr = arr;
        this.queries = queries.map((q, i) => ({ ...q, index: i }));
        this.blockSize = Math.floor(Math.sqrt(arr.length));
        this.answers = Array(queries.length);
        this.currentAnswer = 0;
        this.freq = new Map();
        
        this.solve();
    }
    
    add(index) {
        const val = this.arr[index];
        const oldFreq = this.freq.get(val) || 0;
        this.freq.set(val, oldFreq + 1);
        
        // Update current answer based on problem requirements
        if (oldFreq === 0) {
            this.currentAnswer++;
        }
    }
    
    remove(index) {
        const val = this.arr[index];
        const oldFreq = this.freq.get(val) || 0;
        this.freq.set(val, oldFreq - 1);
        
        // Update current answer based on problem requirements
        if (oldFreq === 1) {
            this.currentAnswer--;
        }
    }
    
    solve() {
        // Sort queries by Mo's order
        this.queries.sort((a, b) => {
            const blockA = Math.floor(a.left / this.blockSize);
            const blockB = Math.floor(b.left / this.blockSize);
            
            if (blockA !== blockB) {
                return blockA - blockB;
            }
            
            return blockA % 2 === 0 ? a.right - b.right : b.right - a.right;
        });
        
        let currentLeft = 0;
        let currentRight = -1;
        
        for (let query of this.queries) {
            const { left, right, index } = query;
            
            // Extend right
            while (currentRight < right) {
                currentRight++;
                this.add(currentRight);
            }
            
            // Shrink right
            while (currentRight > right) {
                this.remove(currentRight);
                currentRight--;
            }
            
            // Extend left
            while (currentLeft > left) {
                currentLeft--;
                this.add(currentLeft);
            }
            
            // Shrink left
            while (currentLeft < left) {
                this.remove(currentLeft);
                currentLeft++;
            }
            
            this.answers[index] = this.currentAnswer;
        }
    }
    
    getAnswers() {
        return this.answers;
    }
}
```

89. **Square Root Decomposition**
```javascript
class SqrtDecomposition {
    constructor(arr) {
        this.n = arr.length;
        this.blockSize = Math.floor(Math.sqrt(this.n));
        this.blocks = Math.ceil(this.n / this.blockSize);
        this.arr = [...arr];
        this.blockSum = Array(this.blocks).fill(0);
        this.lazy = Array(this.blocks).fill(0);
        
        this.build();
    }
    
    build() {
        for (let i = 0; i < this.n; i++) {
            this.blockSum[Math.floor(i / this.blockSize)] += this.arr[i];
        }
    }
    
    update(l, r, val) {
        const leftBlock = Math.floor(l / this.blockSize);
        const rightBlock = Math.floor(r / this.blockSize);
        
        if (leftBlock === rightBlock) {
            for (let i = l; i <= r; i++) {
                this.arr[i] += val;
                this.blockSum[leftBlock] += val;
            }
        } else {
            // Update partial left block
            for (let i = l; i < (leftBlock + 1) * this.blockSize; i++) {
                this.arr[i] += val;
                this.blockSum[leftBlock] += val;
            }
            
            // Update complete middle blocks
            for (let block = leftBlock + 1; block < rightBlock; block++) {
                this.lazy[block] += val;
            }
            
            // Update partial right block
            for (let i = rightBlock * this.blockSize; i <= r; i++) {
                this.arr[i] += val;
                this.blockSum[rightBlock] += val;
            }
        }
    }
    
    query(l, r) {
        const leftBlock = Math.floor(l / this.blockSize);
        const rightBlock = Math.floor(r / this.blockSize);
        let sum = 0;
        
        if (leftBlock === rightBlock) {
            for (let i = l; i <= r; i++) {
                sum += this.arr[i] + this.lazy[leftBlock];
            }
        } else {
            // Query partial left block
            for (let i = l; i < (leftBlock + 1) * this.blockSize; i++) {
                sum += this.arr[i] + this.lazy[leftBlock];
            }
            
            // Query complete middle blocks
            for (let block = leftBlock + 1; block < rightBlock; block++) {
                sum += this.blockSum[block] + this.lazy[block] * this.blockSize;
            }
            
            // Query partial right block
            for (let i = rightBlock * this.blockSize; i <= r; i++) {
                sum += this.arr[i] + this.lazy[rightBlock];
            }
        }
        
        return sum;
    }
}
```

90. **Persistent Segment Tree**
```javascript
class PersistentSegmentTree {
    constructor(arr) {
        this.n = arr.length;
        this.versions = [];
        this.nodeCount = 0;
        
        this.versions.push(this.build(arr, 0, this.n - 1));
    }
    
    createNode(left = null, right = null, sum = 0) {
        return {
            id: this.nodeCount++,
            left,
            right,
            sum
        };
    }
    
    build(arr, start, end) {
        if (start === end) {
            return this.createNode(null, null, arr[start]);
        }
        
        const mid = Math.floor((start + end) / 2);
        const leftChild = this.build(arr, start, mid);
        const rightChild = this.build(arr, mid + 1, end);
        
        return this.createNode(leftChild, rightChild, leftChild.sum + rightChild.sum);
    }
    
    update(prevRoot, start, end, idx, val) {
        if (start === end) {
            return this.createNode(null, null, val);
        }
        
        const mid = Math.floor((start + end) / 2);
        let leftChild = prevRoot.left;
        let rightChild = prevRoot.right;
        
        if (idx <= mid) {
            leftChild = this.update(prevRoot.left, start, mid, idx, val);
        } else {
            rightChild = this.update(prevRoot.right, mid + 1, end, idx, val);
        }
        
        return this.createNode(leftChild, rightChild, leftChild.sum + rightChild.sum);
    }
    
    query(root, start, end, l, r) {
        if (r < start || end < l) return 0;
        if (l <= start && end <= r) return root.sum;
        
        const mid = Math.floor((start + end) / 2);
        return this.query(root.left, start, mid, l, r) + 
               this.query(root.right, mid + 1, end, l, r);
    }
    
    updateVersion(version, idx, val) {
        const newRoot = this.update(this.versions[version], 0, this.n - 1, idx, val);
        this.versions.push(newRoot);
        return this.versions.length - 1;
    }
    
    queryVersion(version, l, r) {
        return this.query(this.versions[version], 0, this.n - 1, l, r);
    }
}
```91.
 **Convex Hull (Graham Scan)**
```javascript
function convexHull(points) {
    if (points.length < 3) return points;
    
    // Find bottom-most point (or left most in case of tie)
    let start = 0;
    for (let i = 1; i < points.length; i++) {
        if (points[i][1] < points[start][1] || 
            (points[i][1] === points[start][1] && points[i][0] < points[start][0])) {
            start = i;
        }
    }
    
    [points[0], points[start]] = [points[start], points[0]];
    
    // Sort points by polar angle with respect to start point
    const startPoint = points[0];
    points.slice(1).sort((a, b) => {
        const angleA = Math.atan2(a[1] - startPoint[1], a[0] - startPoint[0]);
        const angleB = Math.atan2(b[1] - startPoint[1], b[0] - startPoint[0]);
        
        if (angleA === angleB) {
            const distA = (a[0] - startPoint[0]) ** 2 + (a[1] - startPoint[1]) ** 2;
            const distB = (b[0] - startPoint[0]) ** 2 + (b[1] - startPoint[1]) ** 2;
            return distA - distB;
        }
        
        return angleA - angleB;
    });
    
    function ccw(A, B, C) {
        return (C[1] - A[1]) * (B[0] - A[0]) > (B[1] - A[1]) * (C[0] - A[0]);
    }
    
    const hull = [points[0], points[1]];
    
    for (let i = 2; i < points.length; i++) {
        while (hull.length > 1 && !ccw(hull[hull.length - 2], hull[hull.length - 1], points[i])) {
            hull.pop();
        }
        hull.push(points[i]);
    }
    
    return hull;
}
```

92. **Fast Fourier Transform (FFT)**
```javascript
class Complex {
    constructor(real, imag = 0) {
        this.real = real;
        this.imag = imag;
    }
    
    add(other) {
        return new Complex(this.real + other.real, this.imag + other.imag);
    }
    
    subtract(other) {
        return new Complex(this.real - other.real, this.imag - other.imag);
    }
    
    multiply(other) {
        return new Complex(
            this.real * other.real - this.imag * other.imag,
            this.real * other.imag + this.imag * other.real
        );
    }
    
    static fromPolar(magnitude, angle) {
        return new Complex(
            magnitude * Math.cos(angle),
            magnitude * Math.sin(angle)
        );
    }
}

function fft(x, inverse = false) {
    const n = x.length;
    if (n <= 1) return x;
    
    // Bit-reversal permutation
    const result = Array(n);
    for (let i = 0; i < n; i++) {
        let j = 0;
        for (let k = 0; k < Math.log2(n); k++) {
            j = (j << 1) | ((i >> k) & 1);
        }
        result[j] = x[i];
    }
    
    // Cooley-Tukey FFT
    for (let len = 2; len <= n; len <<= 1) {
        const angle = (inverse ? 2 : -2) * Math.PI / len;
        const wlen = Complex.fromPolar(1, angle);
        
        for (let i = 0; i < n; i += len) {
            let w = new Complex(1, 0);
            
            for (let j = 0; j < len / 2; j++) {
                const u = result[i + j];
                const v = result[i + j + len / 2].multiply(w);
                
                result[i + j] = u.add(v);
                result[i + j + len / 2] = u.subtract(v);
                
                w = w.multiply(wlen);
            }
        }
    }
    
    if (inverse) {
        for (let i = 0; i < n; i++) {
            result[i] = new Complex(result[i].real / n, result[i].imag / n);
        }
    }
    
    return result;
}

function multiply(a, b) {
    const n = 1 << Math.ceil(Math.log2(a.length + b.length));
    
    const fa = Array(n).fill(new Complex(0));
    const fb = Array(n).fill(new Complex(0));
    
    for (let i = 0; i < a.length; i++) fa[i] = new Complex(a[i]);
    for (let i = 0; i < b.length; i++) fb[i] = new Complex(b[i]);
    
    const fftA = fft(fa);
    const fftB = fft(fb);
    
    for (let i = 0; i < n; i++) {
        fftA[i] = fftA[i].multiply(fftB[i]);
    }
    
    const result = fft(fftA, true);
    return result.map(c => Math.round(c.real));
}
```

93. **Matrix Exponentiation**
```javascript
function matrixMultiply(A, B) {
    const n = A.length;
    const m = B[0].length;
    const p = B.length;
    const result = Array(n).fill().map(() => Array(m).fill(0));
    
    for (let i = 0; i < n; i++) {
        for (let j = 0; j < m; j++) {
            for (let k = 0; k < p; k++) {
                result[i][j] += A[i][k] * B[k][j];
            }
        }
    }
    
    return result;
}

function matrixPower(matrix, n) {
    const size = matrix.length;
    let result = Array(size).fill().map((_, i) => 
        Array(size).fill().map((_, j) => i === j ? 1 : 0)
    );
    
    let base = matrix.map(row => [...row]);
    
    while (n > 0) {
        if (n % 2 === 1) {
            result = matrixMultiply(result, base);
        }
        base = matrixMultiply(base, base);
        n = Math.floor(n / 2);
    }
    
    return result;
}

function fibonacciMatrix(n) {
    if (n <= 1) return n;
    
    const matrix = [[1, 1], [1, 0]];
    const result = matrixPower(matrix, n - 1);
    
    return result[0][0];
}
```

94. **Chinese Remainder Theorem**
```javascript
function extendedGCD(a, b) {
    if (a === 0) return [b, 0, 1];
    
    const [gcd, x1, y1] = extendedGCD(b % a, a);
    const x = y1 - Math.floor(b / a) * x1;
    const y = x1;
    
    return [gcd, x, y];
}

function modInverse(a, m) {
    const [gcd, x] = extendedGCD(a, m);
    if (gcd !== 1) return null; // Inverse doesn't exist
    return ((x % m) + m) % m;
}

function chineseRemainderTheorem(remainders, moduli) {
    const n = remainders.length;
    let result = remainders[0];
    let lcm = moduli[0];
    
    for (let i = 1; i < n; i++) {
        const a = result;
        const m = lcm;
        const b = remainders[i];
        const n = moduli[i];
        
        const [gcd, p, q] = extendedGCD(m, n);
        
        if ((b - a) % gcd !== 0) {
            return null; // No solution exists
        }
        
        const lcmNew = (m * n) / gcd;
        result = ((a + m * ((b - a) / gcd) * p) % lcmNew + lcmNew) % lcmNew;
        lcm = lcmNew;
    }
    
    return result;
}
```

95. **Miller-Rabin Primality Test**
```javascript
function modularExponentiation(base, exponent, modulus) {
    let result = 1;
    base = base % modulus;
    
    while (exponent > 0) {
        if (exponent % 2 === 1) {
            result = (result * base) % modulus;
        }
        exponent = Math.floor(exponent / 2);
        base = (base * base) % modulus;
    }
    
    return result;
}

function millerRabinTest(n, k = 5) {
    if (n < 2) return false;
    if (n === 2 || n === 3) return true;
    if (n % 2 === 0) return false;
    
    // Write n-1 as d * 2^r
    let r = 0;
    let d = n - 1;
    while (d % 2 === 0) {
        d /= 2;
        r++;
    }
    
    // Witness loop
    for (let i = 0; i < k; i++) {
        const a = 2 + Math.floor(Math.random() * (n - 4));
        let x = modularExponentiation(a, d, n);
        
        if (x === 1 || x === n - 1) continue;
        
        let composite = true;
        for (let j = 0; j < r - 1; j++) {
            x = modularExponentiation(x, 2, n);
            if (x === n - 1) {
                composite = false;
                break;
            }
        }
        
        if (composite) return false;
    }
    
    return true;
}
```

96. **Pollard's Rho Algorithm**
```javascript
function gcd(a, b) {
    while (b !== 0) {
        [a, b] = [b, a % b];
    }
    return a;
}

function pollardRho(n) {
    if (n % 2 === 0) return 2;
    
    let x = 2;
    let y = 2;
    let d = 1;
    
    const f = (x) => (x * x + 1) % n;
    
    while (d === 1) {
        x = f(x);
        y = f(f(y));
        d = gcd(Math.abs(x - y), n);
    }
    
    return d === n ? null : d;
}

function factorize(n) {
    if (n <= 1) return [];
    if (millerRabinTest(n)) return [n];
    
    const factor = pollardRho(n);
    if (factor === null) return [n];
    
    return [...factorize(factor), ...factorize(n / factor)];
}
```

97. **Sieve of Eratosthenes (Optimized)**
```javascript
function sieveOfEratosthenes(n) {
    const isPrime = Array(n + 1).fill(true);
    isPrime[0] = isPrime[1] = false;
    
    for (let i = 2; i * i <= n; i++) {
        if (isPrime[i]) {
            for (let j = i * i; j <= n; j += i) {
                isPrime[j] = false;
            }
        }
    }
    
    return isPrime.map((prime, index) => prime ? index : null)
                 .filter(num => num !== null);
}

function segmentedSieve(low, high) {
    const limit = Math.floor(Math.sqrt(high)) + 1;
    const primes = sieveOfEratosthenes(limit);
    
    const isPrime = Array(high - low + 1).fill(true);
    
    for (let prime of primes) {
        const start = Math.max(prime * prime, Math.ceil(low / prime) * prime);
        
        for (let j = start; j <= high; j += prime) {
            isPrime[j - low] = false;
        }
    }
    
    const result = [];
    for (let i = 0; i < isPrime.length; i++) {
        if (isPrime[i] && (low + i) > 1) {
            result.push(low + i);
        }
    }
    
    return result;
}
```

98. **Gaussian Elimination**
```javascript
function gaussianElimination(matrix) {
    const n = matrix.length;
    const m = matrix[0].length;
    
    // Forward elimination
    for (let i = 0; i < n; i++) {
        // Find pivot
        let maxRow = i;
        for (let k = i + 1; k < n; k++) {
            if (Math.abs(matrix[k][i]) > Math.abs(matrix[maxRow][i])) {
                maxRow = k;
            }
        }
        
        // Swap rows
        [matrix[i], matrix[maxRow]] = [matrix[maxRow], matrix[i]];
        
        // Make all rows below this one 0 in current column
        for (let k = i + 1; k < n; k++) {
            const factor = matrix[k][i] / matrix[i][i];
            for (let j = i; j < m; j++) {
                matrix[k][j] -= factor * matrix[i][j];
            }
        }
    }
    
    // Back substitution
    const solution = Array(n).fill(0);
    for (let i = n - 1; i >= 0; i--) {
        solution[i] = matrix[i][m - 1];
        for (let j = i + 1; j < n; j++) {
            solution[i] -= matrix[i][j] * solution[j];
        }
        solution[i] /= matrix[i][i];
    }
    
    return solution;
}
```

99. **Karatsuba Multiplication**
```javascript
function karatsubaMultiply(x, y) {
    // Convert to strings for easier manipulation
    const xStr = x.toString();
    const yStr = y.toString();
    
    const n = Math.max(xStr.length, yStr.length);
    
    // Base case
    if (n === 1) {
        return x * y;
    }
    
    // Pad with zeros
    const xPadded = xStr.padStart(n, '0');
    const yPadded = yStr.padStart(n, '0');
    
    const mid = Math.floor(n / 2);
    
    const x1 = parseInt(xPadded.substring(0, n - mid));
    const x0 = parseInt(xPadded.substring(n - mid));
    const y1 = parseInt(yPadded.substring(0, n - mid));
    const y0 = parseInt(yPadded.substring(n - mid));
    
    // Recursive calls
    const z2 = karatsubaMultiply(x1, y1);
    const z0 = karatsubaMultiply(x0, y0);
    const z1 = karatsubaMultiply(x1 + x0, y1 + y0) - z2 - z0;
    
    return z2 * Math.pow(10, 2 * mid) + z1 * Math.pow(10, mid) + z0;
}
```

100. **Bloom Filter Implementation**
```javascript
class BloomFilter {
    constructor(size, hashFunctions) {
        this.size = size;
        this.bitArray = Array(size).fill(false);
        this.hashFunctions = hashFunctions;
    }
    
    hash1(item) {
        let hash = 0;
        for (let i = 0; i < item.length; i++) {
            hash = (hash * 31 + item.charCodeAt(i)) % this.size;
        }
        return hash;
    }
    
    hash2(item) {
        let hash = 5381;
        for (let i = 0; i < item.length; i++) {
            hash = ((hash << 5) + hash + item.charCodeAt(i)) % this.size;
        }
        return hash;
    }
    
    hash3(item) {
        let hash = 0;
        for (let i = 0; i < item.length; i++) {
            hash = (hash * 33 + item.charCodeAt(i)) % this.size;
        }
        return hash;
    }
    
    add(item) {
        const hashes = [
            this.hash1(item),
            this.hash2(item),
            this.hash3(item)
        ];
        
        for (let hash of hashes.slice(0, this.hashFunctions)) {
            this.bitArray[hash] = true;
        }
    }
    
    contains(item) {
        const hashes = [
            this.hash1(item),
            this.hash2(item),
            this.hash3(item)
        ];
        
        for (let hash of hashes.slice(0, this.hashFunctions)) {
            if (!this.bitArray[hash]) {
                return false;
            }
        }
        
        return true; // Might be a false positive
    }
    
    falsePositiveRate() {
        const bitsSet = this.bitArray.filter(bit => bit).length;
        return Math.pow(bitsSet / this.size, this.hashFunctions);
    }
}

// Usage example
const bloom = new BloomFilter(1000, 3);
bloom.add("hello");
bloom.add("world");
console.log(bloom.contains("hello")); // true
console.log(bloom.contains("foo"));   // false (probably)
```

---



## Code Output Analysis Questions



### Hoisting and Scope (1-20)

1. **Variable Hoisting**
```javascript
console.log(x);
var x = 5;
console.log(x);
```
**Output:** `undefined`, `5`
**Explanation:** `var` declarations are hoisted but not initialized.

2. **Function Hoisting**
```javascript
console.log(foo());
function foo() {
    return "Hello";
}
console.log(bar());
var bar = function() {
    return "World";
};
```
**Output:** `"Hello"`, `TypeError: bar is not a function`
**Explanation:** Function declarations are fully hoisted, function expressions are not.

3. **Let and Const Hoisting**
```javascript
console.log(a);
console.log(b);
let a = 1;
const b = 2;
```
**Output:** `ReferenceError: Cannot access 'a' before initialization`
**Explanation:** `let` and `const` are hoisted but in temporal dead zone.

4. **Block Scope**
```javascript
for (var i = 0; i < 3; i++) {
    setTimeout(() => console.log(i), 100);
}
for (let j = 0; j < 3; j++) {
    setTimeout(() => console.log(j), 100);
}
```
**Output:** `3 3 3 0 1 2`
**Explanation:** `var` has function scope, `let` has block scope.

5. **Closure Scope**
```javascript
function outer() {
    var x = 1;
    function inner() {
        console.log(x);
    }
    x = 2;
    return inner;
}
outer()();
```
**Output:** `2`
**Explanation:** Closure captures variable reference, not value.6. *
*Function Scope vs Block Scope**
```javascript
function test() {
    if (true) {
        var a = 1;
        let b = 2;
        const c = 3;
    }
    console.log(a);
    console.log(b);
    console.log(c);
}
test();
```
**Output:** `1`, `ReferenceError: b is not defined`
**Explanation:** `var` has function scope, `let` and `const` have block scope.

7. **Temporal Dead Zone**
```javascript
console.log(typeof x);
console.log(typeof y);
let x;
var y;
```
**Output:** `ReferenceError: Cannot access 'x' before initialization`
**Explanation:** `let` variables are in temporal dead zone before declaration.

8. **Nested Function Scope**
```javascript
var x = 1;
function outer() {
    var x = 2;
    function inner() {
        var x = 3;
        console.log(x);
    }
    inner();
    console.log(x);
}
outer();
console.log(x);
```
**Output:** `3`, `2`, `1`
**Explanation:** Each function creates its own scope.

9. **IIFE and Scope**
```javascript
var x = 1;
(function() {
    console.log(x);
    var x = 2;
    console.log(x);
})();
console.log(x);
```
**Output:** `undefined`, `2`, `1`
**Explanation:** Local `var x` is hoisted and shadows global `x`.

10. **Switch Case Scope**
```javascript
switch (1) {
    case 1:
        let x = 1;
        console.log(x);
        break;
    case 2:
        let x = 2;
        console.log(x);
        break;
}
```
**Output:** `SyntaxError: Identifier 'x' has already been declared`
**Explanation:** Switch cases share the same block scope.

### This Binding (21-40)

11. **Global This**
```javascript
console.log(this);
function test() {
    console.log(this);
}
test();
```
**Output:** `Window object` (browser), `Window object` (browser)
**Explanation:** In non-strict mode, `this` refers to global object.

12. **Strict Mode This**
```javascript
"use strict";
function test() {
    console.log(this);
}
test();
```
**Output:** `undefined`
**Explanation:** In strict mode, `this` is `undefined` in regular function calls.

13. **Object Method This**
```javascript
const obj = {
    name: "John",
    greet: function() {
        console.log(this.name);
    }
};
obj.greet();
const greetFunc = obj.greet;
greetFunc();
```
**Output:** `"John"`, `undefined` (or error in strict mode)
**Explanation:** `this` depends on how function is called, not where it's defined.

14. **Arrow Function This**
```javascript
const obj = {
    name: "John",
    greet: () => {
        console.log(this.name);
    },
    sayHi: function() {
        const inner = () => {
            console.log(this.name);
        };
        inner();
    }
};
obj.greet();
obj.sayHi();
```
**Output:** `undefined`, `"John"`
**Explanation:** Arrow functions inherit `this` from enclosing scope.

15. **Constructor This**
```javascript
function Person(name) {
    this.name = name;
    console.log(this);
}
const p1 = new Person("John");
const p2 = Person("Jane");
```
**Output:** `Person {name: "John"}`, `Window object` (and `this.name` sets global variable)
**Explanation:** `new` creates new object and binds it to `this`.

16. **Call, Apply, Bind**
```javascript
const obj1 = { name: "John" };
const obj2 = { name: "Jane" };

function greet(greeting, punctuation) {
    console.log(greeting + " " + this.name + punctuation);
}

greet.call(obj1, "Hello", "!");
greet.apply(obj2, ["Hi", "."]);
const boundGreet = greet.bind(obj1, "Hey");
boundGreet("?");
```
**Output:** `"Hello John!"`, `"Hi Jane."`, `"Hey John?"`
**Explanation:** `call`, `apply`, and `bind` explicitly set `this` context.

17. **Event Handler This**
```javascript
const button = document.createElement('button');
button.textContent = 'Click me';

button.addEventListener('click', function() {
    console.log(this);
});

button.addEventListener('click', () => {
    console.log(this);
});
```
**Output:** `<button>Click me</button>`, `Window object`
**Explanation:** Regular functions get element as `this`, arrow functions inherit `this`.

18. **Class Method This**
```javascript
class MyClass {
    constructor(name) {
        this.name = name;
    }
    
    method1() {
        console.log(this.name);
    }
    
    method2 = () => {
        console.log(this.name);
    }
}

const obj = new MyClass("Test");
const m1 = obj.method1;
const m2 = obj.method2;
m1();
m2();
```
**Output:** `undefined` (or error), `"Test"`
**Explanation:** Regular methods lose `this` when extracted, arrow methods preserve it.

19. **Nested Object This**
```javascript
const obj = {
    name: "Outer",
    inner: {
        name: "Inner",
        greet: function() {
            console.log(this.name);
        }
    }
};
obj.inner.greet();
```
**Output:** `"Inner"`
**Explanation:** `this` refers to the immediate object that calls the method.

20. **Callback This**
```javascript
const obj = {
    name: "John",
    greet: function() {
        console.log(this.name);
    }
};

function callCallback(callback) {
    callback();
}

callCallback(obj.greet);
callCallback(obj.greet.bind(obj));
```
**Output:** `undefined`, `"John"`
**Explanation:** Callbacks lose original `this` unless explicitly bound.

### Closures and Lexical Scope (41-60)

21. **Basic Closure**
```javascript
function outer(x) {
    return function inner(y) {
        return x + y;
    };
}
const add5 = outer(5);
console.log(add5(3));
console.log(add5(7));
```
**Output:** `8`, `12`
**Explanation:** Inner function retains access to outer function's variables.

22. **Closure with Loop**
```javascript
for (var i = 0; i < 3; i++) {
    setTimeout(function() {
        console.log(i);
    }, 100);
}

for (let j = 0; j < 3; j++) {
    setTimeout(function() {
        console.log(j);
    }, 100);
}
```
**Output:** `3 3 3 0 1 2`
**Explanation:** `var` creates one binding, `let` creates new binding per iteration.

23. **Closure Variable Modification**
```javascript
function createCounter() {
    let count = 0;
    return {
        increment: () => ++count,
        decrement: () => --count,
        get: () => count
    };
}
const counter = createCounter();
console.log(counter.increment());
console.log(counter.increment());
console.log(counter.get());
```
**Output:** `1`, `2`, `2`
**Explanation:** Closure maintains private state across function calls.

24. **Multiple Closures**
```javascript
function outer() {
    let x = 1;
    
    function inner1() {
        x++;
        console.log("inner1:", x);
    }
    
    function inner2() {
        x += 2;
        console.log("inner2:", x);
    }
    
    return { inner1, inner2 };
}

const { inner1, inner2 } = outer();
inner1();
inner2();
inner1();
```
**Output:** `"inner1: 2"`, `"inner2: 4"`, `"inner1: 5"`
**Explanation:** Multiple functions can share the same closure scope.

25. **Closure Memory**
```javascript
function heavyFunction() {
    const largeArray = new Array(1000000).fill('data');
    
    return function() {
        return largeArray.length;
    };
}

const func = heavyFunction();
console.log(func());
```
**Output:** `1000000`
**Explanation:** Closure keeps reference to entire scope, potentially causing memory leaks.

### Prototypes and Inheritance (61-80)

26. **Prototype Chain**
```javascript
function Animal(name) {
    this.name = name;
}
Animal.prototype.speak = function() {
    return this.name + " makes a sound";
};

function Dog(name) {
    Animal.call(this, name);
}
Dog.prototype = Object.create(Animal.prototype);
Dog.prototype.constructor = Dog;
Dog.prototype.speak = function() {
    return this.name + " barks";
};

const dog = new Dog("Rex");
console.log(dog.speak());
console.log(dog instanceof Dog);
console.log(dog instanceof Animal);
```
**Output:** `"Rex barks"`, `true`, `true`
**Explanation:** Prototype chain enables inheritance and method overriding.

27. **Prototype Property Access**
```javascript
function Person(name) {
    this.name = name;
}
Person.prototype.age = 25;

const person1 = new Person("John");
const person2 = new Person("Jane");

console.log(person1.age);
person1.age = 30;
console.log(person1.age);
console.log(person2.age);
delete person1.age;
console.log(person1.age);
```
**Output:** `25`, `30`, `25`, `25`
**Explanation:** Instance properties shadow prototype properties.

28. **Object.create**
```javascript
const parent = {
    greet: function() {
        return "Hello from " + this.name;
    }
};

const child = Object.create(parent);
child.name = "Child";

console.log(child.greet());
console.log(child.hasOwnProperty('greet'));
console.log(child.hasOwnProperty('name'));
```
**Output:** `"Hello from Child"`, `false`, `true`
**Explanation:** `Object.create` sets up prototype chain without constructor.

29. **Class Inheritance**
```javascript
class Animal {
    constructor(name) {
        this.name = name;
    }
    
    speak() {
        return `${this.name} makes a sound`;
    }
}

class Dog extends Animal {
    speak() {
        return `${this.name} barks`;
    }
}

const dog = new Dog("Rex");
console.log(dog.speak());
console.log(Object.getPrototypeOf(dog) === Dog.prototype);
console.log(Object.getPrototypeOf(Dog.prototype) === Animal.prototype);
```
**Output:** `"Rex barks"`, `true`, `true`
**Explanation:** Class syntax creates same prototype chain as function constructors.

30. **Super Keyword**
```javascript
class Animal {
    constructor(name) {
        this.name = name;
    }
    
    speak() {
        return `${this.name} makes a sound`;
    }
}

class Dog extends Animal {
    constructor(name, breed) {
        super(name);
        this.breed = breed;
    }
    
    speak() {
        return super.speak() + " - specifically barks";
    }
}

const dog = new Dog("Rex", "German Shepherd");
console.log(dog.speak());
```
**Output:** `"Rex makes a sound - specifically barks"`
**Explanation:** `super` calls parent class methods and constructor.

### Asynchronous JavaScript (81-100)

31. **Event Loop Basics**
```javascript
console.log("1");
setTimeout(() => console.log("2"), 0);
console.log("3");
Promise.resolve().then(() => console.log("4"));
console.log("5");
```
**Output:** `1`, `3`, `5`, `4`, `2`
**Explanation:** Microtasks (Promises) have higher priority than macrotasks (setTimeout).

32. **Promise Chain**
```javascript
Promise.resolve(1)
    .then(x => {
        console.log(x);
        return x + 1;
    })
    .then(x => {
        console.log(x);
        throw new Error("Error!");
    })
    .then(x => {
        console.log("This won't run");
    })
    .catch(err => {
        console.log("Caught:", err.message);
        return 10;
    })
    .then(x => {
        console.log(x);
    });
```
**Output:** `1`, `2`, `"Caught: Error!"`, `10`
**Explanation:** Promise chain continues after catch, returning resolved promise.

33. **Async/Await Error Handling**
```javascript
async function test() {
    try {
        const result = await Promise.reject("Error!");
        console.log(result);
    } catch (error) {
        console.log("Caught:", error);
        return "Success";
    }
}

test().then(result => console.log("Final:", result));
```
**Output:** `"Caught: Error!"`, `"Final: Success"`
**Explanation:** Try-catch works with async/await, function returns resolved promise.

34. **Promise.all vs Promise.allSettled**
```javascript
const p1 = Promise.resolve(1);
const p2 = Promise.reject("Error");
const p3 = Promise.resolve(3);

Promise.all([p1, p2, p3])
    .then(results => console.log("All:", results))
    .catch(error => console.log("All Error:", error));

Promise.allSettled([p1, p2, p3])
    .then(results => console.log("AllSettled:", results));
```
**Output:** 
```
"All Error: Error"
"AllSettled: [
  {status: 'fulfilled', value: 1},
  {status: 'rejected', reason: 'Error'},
  {status: 'fulfilled', value: 3}
]"
```
**Explanation:** `Promise.all` fails fast, `Promise.allSettled` waits for all.

35. **Microtask vs Macrotask**
```javascript
console.log("Start");

setTimeout(() => console.log("Timeout 1"), 0);
setTimeout(() => console.log("Timeout 2"), 0);

Promise.resolve().then(() => {
    console.log("Promise 1");
    return Promise.resolve();
}).then(() => {
    console.log("Promise 2");
});

queueMicrotask(() => console.log("Microtask"));

console.log("End");
```
**Output:** `"Start"`, `"End"`, `"Promise 1"`, `"Microtask"`, `"Promise 2"`, `"Timeout 1"`, `"Timeout 2"`
**Explanation:** All microtasks execute before any macrotask.

### Type Coercion and Equality (101-120)

36. **Equality Operators**
```javascript
console.log(0 == false);
console.log(0 === false);
console.log("" == false);
console.log("" === false);
console.log(null == undefined);
console.log(null === undefined);
```
**Output:** `true`, `false`, `true`, `false`, `true`, `false`
**Explanation:** `==` performs type coercion, `===` doesn't.

37. **String to Number Coercion**
```javascript
console.log("5" - 3);
console.log("5" + 3);
console.log(+"5");
console.log(Number("5"));
console.log(parseInt("5.7"));
console.log(parseFloat("5.7"));
```
**Output:** `2`, `"53"`, `5`, `5`, `5`, `5.7`
**Explanation:** Different operators and functions handle string-to-number conversion differently.

38. **Truthy and Falsy**
```javascript
console.log(Boolean(0));
console.log(Boolean(""));
console.log(Boolean(null));
console.log(Boolean(undefined));
console.log(Boolean(NaN));
console.log(Boolean(false));
console.log(Boolean([]));
console.log(Boolean({}));
```
**Output:** `false`, `false`, `false`, `false`, `false`, `false`, `true`, `true`
**Explanation:** Only 6 falsy values in JavaScript, everything else is truthy.

39. **Object to Primitive Conversion**
```javascript
const obj = {
    valueOf: () => 42,
    toString: () => "hello"
};

console.log(obj + 1);
console.log(String(obj));
console.log(Number(obj));
console.log(obj == 42);
```
**Output:** `43`, `"hello"`, `42`, `true`
**Explanation:** Objects convert to primitives using `valueOf` and `toString` methods.

40. **Array Coercion**
```javascript
console.log([1, 2, 3] + [4, 5, 6]);
console.log([1, 2, 3] - [1]);
console.log([5] - [2]);
console.log([] + []);
console.log([] + {});
console.log({} + []);
```
**Output:** `"1,2,34,5,6"`, `NaN`, `3`, `""`, `"[object Object]"`, `"[object Object]"`
**Explanation:** Arrays convert to strings for `+` operator, to numbers for `-` operator.

### Advanced Concepts (121-150)

41. **Generator Functions**
```javascript
function* generator() {
    console.log("Start");
    yield 1;
    console.log("Middle");
    yield 2;
    console.log("End");
    return 3;
}

const gen = generator();
console.log(gen.next());
console.log(gen.next());
console.log(gen.next());
```
**Output:** 
```
"Start"
{value: 1, done: false}
"Middle"
{value: 2, done: false}
"End"
{value: 3, done: true}
```
**Explanation:** Generators pause execution at `yield` and resume on `next()`.

42. **Proxy Object**
```javascript
const target = { name: "John", age: 30 };
const proxy = new Proxy(target, {
    get(obj, prop) {
        console.log(`Getting ${prop}`);
        return obj[prop];
    },
    set(obj, prop, value) {
        console.log(`Setting ${prop} to ${value}`);
        obj[prop] = value;
        return true;
    }
});

console.log(proxy.name);
proxy.age = 31;
console.log(proxy.age);
```
**Output:** 
```
"Getting name"
"John"
"Setting age to 31"
"Getting age"
31
```
**Explanation:** Proxy intercepts and customizes object operations.

43. **Symbol Properties**
```javascript
const sym1 = Symbol("id");
const sym2 = Symbol("id");
const obj = {
    [sym1]: "value1",
    [sym2]: "value2",
    regular: "regular"
};

console.log(sym1 === sym2);
console.log(obj[sym1]);
console.log(Object.keys(obj));
console.log(Object.getOwnPropertySymbols(obj));
```
**Output:** `false`, `"value1"`, `["regular"]`, `[Symbol(id), Symbol(id)]`
**Explanation:** Symbols are unique and don't appear in regular property enumeration.

44. **WeakMap and WeakSet**
```javascript
let obj1 = { name: "John" };
let obj2 = { name: "Jane" };

const weakMap = new WeakMap();
weakMap.set(obj1, "data for John");
weakMap.set(obj2, "data for Jane");

console.log(weakMap.get(obj1));
console.log(weakMap.has(obj2));

obj1 = null; // obj1 can now be garbage collected
console.log(weakMap.has(obj1)); // false, but we can't test garbage collection directly
```
**Output:** `"data for John"`, `true`, `false`
**Explanation:** WeakMap holds weak references, allowing garbage collection.

45. **Destructuring Edge Cases**
```javascript
const [a, b, c = 3] = [1, 2];
const [x, y, ...rest] = [1, 2, 3, 4, 5];
const { name: personName, age = 25 } = { name: "John" };
const { p, q } = { p: 1, q: 2, r: 3 };

console.log(a, b, c);
console.log(x, y, rest);
console.log(personName, age);
console.log(p, q);
```
**Output:** `1 2 3`, `1 2 [3, 4, 5]`, `"John" 25`, `1 2`
**Explanation:** Destructuring supports default values, rest patterns, and renaming.

### Memory and Performance (151-170)

46. **Memory Leaks**
```javascript
function createLeak() {
    const largeArray = new Array(1000000).fill("data");
    
    return function() {
        // This closure keeps largeArray in memory
        return largeArray.length;
    };
}

const leak = createLeak();
console.log(leak());
// largeArray is still in memory due to closure
```
**Output:** `1000000`
**Explanation:** Closures can prevent garbage collection of large objects.

47. **Event Loop Blocking**
```javascript
console.log("Start");

// Blocking operation
const start = Date.now();
while (Date.now() - start < 1000) {
    // Block for 1 second
}

console.log("After blocking");
setTimeout(() => console.log("Timeout"), 0);
console.log("End");
```
**Output:** `"Start"`, (1 second delay), `"After blocking"`, `"End"`, `"Timeout"`
**Explanation:** Synchronous operations block the event loop.

48. **Stack Overflow**
```javascript
function recursiveFunction(n) {
    console.log(n);
    if (n > 0) {
        return recursiveFunction(n - 1);
    }
}

try {
    recursiveFunction(10000);
} catch (error) {
    console.log("Error:", error.name);
}
```
**Output:** Numbers from 10000 down, then `"Error: RangeError"`
**Explanation:** Deep recursion can cause stack overflow.

49. **Tail Call Optimization (Not in most engines)**
```javascript
function factorial(n, acc = 1) {
    if (n <= 1) return acc;
    return factorial(n - 1, n * acc); // Tail call
}

function factorialNonTail(n) {
    if (n <= 1) return 1;
    return n * factorialNonTail(n - 1); // Not tail call
}

console.log(factorial(5));
console.log(factorialNonTail(5));
```
**Output:** `120`, `120`
**Explanation:** Tail call optimization is not widely implemented in JavaScript engines.

50. **Object Property Performance**
```javascript
const obj = {};
const map = new Map();

// Adding properties
console.time("Object");
for (let i = 0; i < 1000000; i++) {
    obj[i] = i;
}
console.timeEnd("Object");

console.time("Map");
for (let i = 0; i < 1000000; i++) {
    map.set(i, i);
}
console.timeEnd("Map");
```
**Output:** Timing results (varies by engine)
**Explanation:** Maps can be more efficient for frequent additions/deletions.

---

## Additional Advanced Output Analysis

### Module System and Imports

51. **Module Hoisting**
```javascript
// file1.js
console.log("File1 executing");
export const value = getValue();

function getValue() {
    console.log("getValue called");
    return 42;
}

// file2.js
import { value } from './file1.js';
console.log("File2 executing");
console.log(value);
```
**Output:** `"File1 executing"`, `"getValue called"`, `"File2 executing"`, `42`
**Explanation:** Module code executes when first imported, exports are hoisted.

52. **Circular Dependencies**
```javascript
// a.js
import { b } from './b.js';
export const a = 'a';
console.log('a.js:', b);

// b.js
import { a } from './a.js';
export const b = 'b';
console.log('b.js:', a);
```
**Output:** `"b.js: undefined"`, `"a.js: b"`
**Explanation:** Circular imports can result in undefined values during initialization.

### Error Handling Edge Cases

53. **Finally Block Execution**
```javascript
function test() {
    try {
        return "try";
    } catch (e) {
        return "catch";
    } finally {
        return "finally";
    }
}

console.log(test());
```
**Output:** `"finally"`
**Explanation:** Finally block return value overrides try/catch return values.

54. **Error in Finally**
```javascript
function test() {
    try {
        throw new Error("try error");
    } finally {
        throw new Error("finally error");
    }
}

try {
    test();
} catch (e) {
    console.log(e.message);
}
```
**Output:** `"finally error"`
**Explanation:** Errors in finally block override try block errors.

### Regular Expression Edge Cases

55. **Regex Global Flag**
```javascript
const regex = /test/g;
const str = "test test test";

console.log(regex.test(str));
console.log(regex.test(str));
console.log(regex.test(str));
console.log(regex.test(str));
```
**Output:** `true`, `true`, `true`, `false`
**Explanation:** Global regex maintains lastIndex state between calls.

This completes the comprehensive JavaScript interview preparation document with 200+ interview questions, 100 coding challenges, and extensive code output analysis covering all major JavaScript concepts and edge cases!