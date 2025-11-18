# DSA Interview Questions in Java - Complete Guide

Comprehensive Data Structures and Algorithms interview preparation materials with practical Java code examples. This guide covers all essential DSA topics with 30+ questions each, commonly asked in technical interviews at top tech companies.

## Table of Contents
1. [Arrays (30+ Questions)](#arrays)
2. [Strings (30+ Questions)](#strings)
3. [Linked Lists (30+ Questions)](#linked-lists)
4. [Stacks and Queues (30+ Questions)](#stacks-and-queues)
5. [Trees (30+ Questions)](#trees)
6. [Graphs (30+ Questions)](#graphs)
7. [Dynamic Programming (30+ Questions)](#dynamic-programming)
8. [Sorting and Searching (30+ Questions)](#sorting-and-searching)
9. [Hashing (30+ Questions)](#hashing)
10. [Heap (30+ Questions)](#heap)
11. [Backtracking (30+ Questions)](#backtracking)
12. [Greedy Algorithms (30+ Questions)](#greedy-algorithms)
13. [Bit Manipulation (30+ Questions)](#bit-manipulation)
14. [Math and Number Theory (30+ Questions)](#math-and-number-theory)
15. [Two Pointers (30+ Questions)](#two-pointers)
16. [Sliding Window (30+ Questions)](#sliding-window)

---

## Arrays

### 1. Two Sum Problem
**Problem**: Find two numbers in array that add up to target.
```java
public int[] twoSum(int[] nums, int target) {
    Map<Integer, Integer> map = new HashMap<>();
    
    for (int i = 0; i < nums.length; i++) {
        int complement = target - nums[i];
        if (map.containsKey(complement)) {
            return new int[]{map.get(complement), i};
        }
        map.put(nums[i], i);
    }
    
    return new int[]{};
}
```

### 2. Maximum Subarray (Kadane's Algorithm)
**Problem**: Find the contiguous subarray with the largest sum.
```java
public int maxSubArray(int[] nums) {
    int maxSoFar = nums[0];
    int maxEndingHere = nums[0];
    
    for (int i = 1; i < nums.length; i++) {
        maxEndingHere = Math.max(nums[i], maxEndingHere + nums[i]);
        maxSoFar = Math.max(maxSoFar, maxEndingHere);
    }
    
    return maxSoFar;
}
```

### 3. Rotate Array
**Problem**: Rotate array to the right by k steps.
```java
public void rotate(int[] nums, int k) {
    k = k % nums.length;
    reverse(nums, 0, nums.length - 1);
    reverse(nums, 0, k - 1);
    reverse(nums, k, nums.length - 1);
}

private void reverse(int[] nums, int start, int end) {
    while (start < end) {
        int temp = nums[start];
        nums[start] = nums[end];
        nums[end] = temp;
        start++;
        end--;
    }
}
```

### 4. Contains Duplicate
**Problem**: Check if array contains any duplicates.
```java
public boolean containsDuplicate(int[] nums) {
    Set<Integer> seen = new HashSet<>();
    
    for (int num : nums) {
        if (seen.contains(num)) {
            return true;
        }
        seen.add(num);
    }
    
    return false;
}
```

### 5. Product of Array Except Self
**Problem**: Return array where each element is product of all elements except itself.
```java
public int[] productExceptSelf(int[] nums) {
    int n = nums.length;
    int[] result = new int[n];
    
    // Left products
    result[0] = 1;
    for (int i = 1; i < n; i++) {
        result[i] = result[i - 1] * nums[i - 1];
    }
    
    // Right products
    int right = 1;
    for (int i = n - 1; i >= 0; i--) {
        result[i] *= right;
        right *= nums[i];
    }
    
    return result;
}
```

### 6. Best Time to Buy and Sell Stock
**Problem**: Find maximum profit from buying and selling stock once.
```java
public int maxProfit(int[] prices) {
    int minPrice = Integer.MAX_VALUE;
    int maxProfit = 0;
    
    for (int price : prices) {
        if (price < minPrice) {
            minPrice = price;
        } else if (price - minPrice > maxProfit) {
            maxProfit = price - minPrice;
        }
    }
    
    return maxProfit;
}
```

### 7. Find Missing Number
**Problem**: Find missing number in array containing n distinct numbers from 0 to n.
```java
public int missingNumber(int[] nums) {
    int n = nums.length;
    int expectedSum = n * (n + 1) / 2;
    int actualSum = 0;
    
    for (int num : nums) {
        actualSum += num;
    }
    
    return expectedSum - actualSum;
}
```

### 8. Move Zeros
**Problem**: Move all zeros to end while maintaining relative order.
```java
public void moveZeroes(int[] nums) {
    int writeIndex = 0;
    
    // Move non-zero elements to front
    for (int i = 0; i < nums.length; i++) {
        if (nums[i] != 0) {
            nums[writeIndex++] = nums[i];
        }
    }
    
    // Fill remaining positions with zeros
    while (writeIndex < nums.length) {
        nums[writeIndex++] = 0;
    }
}
```

### 9. Container With Most Water
**Problem**: Find two lines that form container holding most water.
```java
public int maxArea(int[] height) {
    int left = 0;
    int right = height.length - 1;
    int maxArea = 0;
    
    while (left < right) {
        int area = Math.min(height[left], height[right]) * (right - left);
        maxArea = Math.max(maxArea, area);
        
        if (height[left] < height[right]) {
            left++;
        } else {
            right--;
        }
    }
    
    return maxArea;
}
```

### 10. 3Sum
**Problem**: Find all unique triplets that sum to zero.
```java
public List<List<Integer>> threeSum(int[] nums) {
    List<List<Integer>> result = new ArrayList<>();
    Arrays.sort(nums);
    
    for (int i = 0; i < nums.length - 2; i++) {
        if (i > 0 && nums[i] == nums[i - 1]) continue;
        
        int left = i + 1;
        int right = nums.length - 1;
        
        while (left < right) {
            int sum = nums[i] + nums[left] + nums[right];
            
            if (sum == 0) {
                result.add(Arrays.asList(nums[i], nums[left], nums[right]));
                
                while (left < right && nums[left] == nums[left + 1]) left++;
                while (left < right && nums[right] == nums[right - 1]) right--;
                
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
```

### 11. Remove Duplicates from Sorted Array
**Problem**: Remove duplicates in-place and return new length.
```java
public int removeDuplicates(int[] nums) {
    if (nums.length == 0) return 0;
    
    int writeIndex = 1;
    
    for (int i = 1; i < nums.length; i++) {
        if (nums[i] != nums[i - 1]) {
            nums[writeIndex++] = nums[i];
        }
    }
    
    return writeIndex;
}
```

### 12. Merge Sorted Array
**Problem**: Merge two sorted arrays in-place.
```java
public void merge(int[] nums1, int m, int[] nums2, int n) {
    int i = m - 1;
    int j = n - 1;
    int k = m + n - 1;
    
    while (i >= 0 && j >= 0) {
        if (nums1[i] > nums2[j]) {
            nums1[k--] = nums1[i--];
        } else {
            nums1[k--] = nums2[j--];
        }
    }
    
    while (j >= 0) {
        nums1[k--] = nums2[j--];
    }
}
```

### 13. Plus One
**Problem**: Add one to number represented as array of digits.
```java
public int[] plusOne(int[] digits) {
    for (int i = digits.length - 1; i >= 0; i--) {
        if (digits[i] < 9) {
            digits[i]++;
            return digits;
        }
        digits[i] = 0;
    }
    
    // Need extra digit
    int[] result = new int[digits.length + 1];
    result[0] = 1;
    return result;
}
```

### 14. Pascal's Triangle
**Problem**: Generate Pascal's triangle with numRows rows.
```java
public List<List<Integer>> generate(int numRows) {
    List<List<Integer>> triangle = new ArrayList<>();
    
    for (int i = 0; i < numRows; i++) {
        List<Integer> row = new ArrayList<>();
        
        for (int j = 0; j <= i; j++) {
            if (j == 0 || j == i) {
                row.add(1);
            } else {
                int val = triangle.get(i - 1).get(j - 1) + triangle.get(i - 1).get(j);
                row.add(val);
            }
        }
        
        triangle.add(row);
    }
    
    return triangle;
}
```

### 15. Majority Element
**Problem**: Find element that appears more than n/2 times.
```java
public int majorityElement(int[] nums) {
    int candidate = nums[0];
    int count = 1;
    
    for (int i = 1; i < nums.length; i++) {
        if (nums[i] == candidate) {
            count++;
        } else {
            count--;
            if (count == 0) {
                candidate = nums[i];
                count = 1;
            }
        }
    }
    
    return candidate;
}
```

### 16. Rotate Image
**Problem**: Rotate n×n 2D matrix by 90 degrees clockwise.
```java
public void rotate(int[][] matrix) {
    int n = matrix.length;
    
    // Transpose matrix
    for (int i = 0; i < n; i++) {
        for (int j = i; j < n; j++) {
            int temp = matrix[i][j];
            matrix[i][j] = matrix[j][i];
            matrix[j][i] = temp;
        }
    }
    
    // Reverse each row
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n / 2; j++) {
            int temp = matrix[i][j];
            matrix[i][j] = matrix[i][n - 1 - j];
            matrix[i][n - 1 - j] = temp;
        }
    }
}
```

### 17. Spiral Matrix
**Problem**: Return elements of matrix in spiral order.
```java
public List<Integer> spiralOrder(int[][] matrix) {
    List<Integer> result = new ArrayList<>();
    if (matrix.length == 0) return result;
    
    int top = 0, bottom = matrix.length - 1;
    int left = 0, right = matrix[0].length - 1;
    
    while (top <= bottom && left <= right) {
        // Traverse right
        for (int j = left; j <= right; j++) {
            result.add(matrix[top][j]);
        }
        top++;
        
        // Traverse down
        for (int i = top; i <= bottom; i++) {
            result.add(matrix[i][right]);
        }
        right--;
        
        if (top <= bottom) {
            // Traverse left
            for (int j = right; j >= left; j--) {
                result.add(matrix[bottom][j]);
            }
            bottom--;
        }
        
        if (left <= right) {
            // Traverse up
            for (int i = bottom; i >= top; i--) {
                result.add(matrix[i][left]);
            }
            left++;
        }
    }
    
    return result;
}
```

### 18. Set Matrix Zeroes
**Problem**: Set entire row and column to zero if element is zero.
```java
public void setZeroes(int[][] matrix) {
    boolean firstRowZero = false;
    boolean firstColZero = false;
    
    // Check if first row has zero
    for (int j = 0; j < matrix[0].length; j++) {
        if (matrix[0][j] == 0) {
            firstRowZero = true;
            break;
        }
    }
    
    // Check if first column has zero
    for (int i = 0; i < matrix.length; i++) {
        if (matrix[i][0] == 0) {
            firstColZero = true;
            break;
        }
    }
    
    // Use first row and column as markers
    for (int i = 1; i < matrix.length; i++) {
        for (int j = 1; j < matrix[0].length; j++) {
            if (matrix[i][j] == 0) {
                matrix[i][0] = 0;
                matrix[0][j] = 0;
            }
        }
    }
    
    // Set zeros based on markers
    for (int i = 1; i < matrix.length; i++) {
        for (int j = 1; j < matrix[0].length; j++) {
            if (matrix[i][0] == 0 || matrix[0][j] == 0) {
                matrix[i][j] = 0;
            }
        }
    }
    
    // Handle first row and column
    if (firstRowZero) {
        for (int j = 0; j < matrix[0].length; j++) {
            matrix[0][j] = 0;
        }
    }
    
    if (firstColZero) {
        for (int i = 0; i < matrix.length; i++) {
            matrix[i][0] = 0;
        }
    }
}
```

### 19. Search in Rotated Sorted Array
**Problem**: Search target in rotated sorted array.
```java
public int search(int[] nums, int target) {
    int left = 0;
    int right = nums.length - 1;
    
    while (left <= right) {
        int mid = left + (right - left) / 2;
        
        if (nums[mid] == target) {
            return mid;
        }
        
        if (nums[left] <= nums[mid]) {
            // Left half is sorted
            if (nums[left] <= target && target < nums[mid]) {
                right = mid - 1;
            } else {
                left = mid + 1;
            }
        } else {
            // Right half is sorted
            if (nums[mid] < target && target <= nums[right]) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }
    }
    
    return -1;
}
```

### 20. Find Peak Element
**Problem**: Find peak element (greater than neighbors).
```java
public int findPeakElement(int[] nums) {
    int left = 0;
    int right = nums.length - 1;
    
    while (left < right) {
        int mid = left + (right - left) / 2;
        
        if (nums[mid] > nums[mid + 1]) {
            right = mid;
        } else {
            left = mid + 1;
        }
    }
    
    return left;
}
```

### 21. Next Permutation
**Problem**: Find next lexicographically greater permutation.
```java
public void nextPermutation(int[] nums) {
    int i = nums.length - 2;
    
    // Find first decreasing element from right
    while (i >= 0 && nums[i] >= nums[i + 1]) {
        i--;
    }
    
    if (i >= 0) {
        // Find element just larger than nums[i]
        int j = nums.length - 1;
        while (nums[j] <= nums[i]) {
            j--;
        }
        swap(nums, i, j);
    }
    
    // Reverse the suffix
    reverse(nums, i + 1, nums.length - 1);
}

private void swap(int[] nums, int i, int j) {
    int temp = nums[i];
    nums[i] = nums[j];
    nums[j] = temp;
}

private void reverse(int[] nums, int start, int end) {
    while (start < end) {
        swap(nums, start++, end--);
    }
}
```

### 22. Trapping Rain Water
**Problem**: Calculate trapped rainwater.
```java
public int trap(int[] height) {
    if (height == null || height.length == 0) {
        return 0;
    }
    
    int left = 0;
    int right = height.length - 1;
    int leftMax = 0;
    int rightMax = 0;
    int water = 0;
    
    while (left < right) {
        if (height[left] < height[right]) {
            if (height[left] >= leftMax) {
                leftMax = height[left];
            } else {
                water += leftMax - height[left];
            }
            left++;
        } else {
            if (height[right] >= rightMax) {
                rightMax = height[right];
            } else {
                water += rightMax - height[right];
            }
            right--;
        }
    }
    
    return water;
}
```

### 23. Jump Game
**Problem**: Determine if you can reach last index.
```java
public boolean canJump(int[] nums) {
    int maxReach = 0;
    
    for (int i = 0; i < nums.length; i++) {
        if (i > maxReach) {
            return false;
        }
        maxReach = Math.max(maxReach, i + nums[i]);
    }
    
    return true;
}
```

### 24. Jump Game II
**Problem**: Find minimum jumps to reach last index.
```java
public int jump(int[] nums) {
    int jumps = 0;
    int currentEnd = 0;
    int farthest = 0;
    
    for (int i = 0; i < nums.length - 1; i++) {
        farthest = Math.max(farthest, i + nums[i]);
        
        if (i == currentEnd) {
            jumps++;
            currentEnd = farthest;
        }
    }
    
    return jumps;
}
```

### 25. Subarray Sum Equals K
**Problem**: Count subarrays with sum equal to k.
```java
public int subarraySum(int[] nums, int k) {
    Map<Integer, Integer> sumCount = new HashMap<>();
    sumCount.put(0, 1);
    
    int count = 0;
    int sum = 0;
    
    for (int num : nums) {
        sum += num;
        
        if (sumCount.containsKey(sum - k)) {
            count += sumCount.get(sum - k);
        }
        
        sumCount.put(sum, sumCount.getOrDefault(sum, 0) + 1);
    }
    
    return count;
}
```

### 26. Maximum Product Subarray
**Problem**: Find contiguous subarray with maximum product.
```java
public int maxProduct(int[] nums) {
    int maxSoFar = nums[0];
    int minSoFar = nums[0];
    int result = nums[0];
    
    for (int i = 1; i < nums.length; i++) {
        int temp = maxSoFar;
        maxSoFar = Math.max(nums[i], Math.max(maxSoFar * nums[i], minSoFar * nums[i]));
        minSoFar = Math.min(nums[i], Math.min(temp * nums[i], minSoFar * nums[i]));
        result = Math.max(result, maxSoFar);
    }
    
    return result;
}
```

### 27. Find All Duplicates in Array
**Problem**: Find all duplicates in array where 1 ≤ a[i] ≤ n.
```java
public List<Integer> findDuplicates(int[] nums) {
    List<Integer> result = new ArrayList<>();
    
    for (int i = 0; i < nums.length; i++) {
        int index = Math.abs(nums[i]) - 1;
        
        if (nums[index] < 0) {
            result.add(Math.abs(nums[i]));
        } else {
            nums[index] = -nums[index];
        }
    }
    
    return result;
}
```

### 28. First Missing Positive
**Problem**: Find smallest missing positive integer.
```java
public int firstMissingPositive(int[] nums) {
    int n = nums.length;
    
    // Place each positive integer i at index i-1
    for (int i = 0; i < n; i++) {
        while (nums[i] > 0 && nums[i] <= n && nums[nums[i] - 1] != nums[i]) {
            int temp = nums[nums[i] - 1];
            nums[nums[i] - 1] = nums[i];
            nums[i] = temp;
        }
    }
    
    // Find first missing positive
    for (int i = 0; i < n; i++) {
        if (nums[i] != i + 1) {
            return i + 1;
        }
    }
    
    return n + 1;
}
```

### 29. Median of Two Sorted Arrays
**Problem**: Find median of two sorted arrays.
```java
public double findMedianSortedArrays(int[] nums1, int[] nums2) {
    if (nums1.length > nums2.length) {
        return findMedianSortedArrays(nums2, nums1);
    }
    
    int x = nums1.length;
    int y = nums2.length;
    int low = 0;
    int high = x;
    
    while (low <= high) {
        int cutX = (low + high) / 2;
        int cutY = (x + y + 1) / 2 - cutX;
        
        int maxLeftX = (cutX == 0) ? Integer.MIN_VALUE : nums1[cutX - 1];
        int minRightX = (cutX == x) ? Integer.MAX_VALUE : nums1[cutX];
        
        int maxLeftY = (cutY == 0) ? Integer.MIN_VALUE : nums2[cutY - 1];
        int minRightY = (cutY == y) ? Integer.MAX_VALUE : nums2[cutY];
        
        if (maxLeftX <= minRightY && maxLeftY <= minRightX) {
            if ((x + y) % 2 == 0) {
                return ((double)Math.max(maxLeftX, maxLeftY) + 
                        Math.min(minRightX, minRightY)) / 2;
            } else {
                return (double)Math.max(maxLeftX, maxLeftY);
            }
        } else if (maxLeftX > minRightY) {
            high = cutX - 1;
        } else {
            low = cutX + 1;
        }
    }
    
    return 1.0;
}
```

### 30. Sliding Window Maximum
**Problem**: Find maximum in each sliding window of size k.
```java
public int[] maxSlidingWindow(int[] nums, int k) {
    if (nums == null || nums.length == 0) {
        return new int[0];
    }
    
    int n = nums.length;
    int[] result = new int[n - k + 1];
    Deque<Integer> deque = new ArrayDeque<>();
    
    for (int i = 0; i < n; i++) {
        // Remove elements outside window
        while (!deque.isEmpty() && deque.peekFirst() < i - k + 1) {
            deque.pollFirst();
        }
        
        // Remove smaller elements
        while (!deque.isEmpty() && nums[deque.peekLast()] < nums[i]) {
            deque.pollLast();
        }
        
        deque.offerLast(i);
        
        if (i >= k - 1) {
            result[i - k + 1] = nums[deque.peekFirst()];
        }
    }
    
    return result;
}
```

---

## Strings

### 1. Valid Anagram
**Problem**: Check if two strings are anagrams.
```java
public boolean isAnagram(String s, String t) {
    if (s.length() != t.length()) {
        return false;
    }
    
    int[] count = new int[26];
    
    for (int i = 0; i < s.length(); i++) {
        count[s.charAt(i) - 'a']++;
        count[t.charAt(i) - 'a']--;
    }
    
    for (int c : count) {
        if (c != 0) {
            return false;
        }
    }
    
    return true;
}
```

### 2. Valid Palindrome
**Problem**: Check if string is a palindrome (ignoring case and non-alphanumeric).
```java
public boolean isPalindrome(String s) {
    int left = 0, right = s.length() - 1;
    
    while (left < right) {
        while (left < right && !Character.isLetterOrDigit(s.charAt(left))) {
            left++;
        }
        while (left < right && !Character.isLetterOrDigit(s.charAt(right))) {
            right--;
        }
        
        if (Character.toLowerCase(s.charAt(left)) != 
            Character.toLowerCase(s.charAt(right))) {
            return false;
        }
        
        left++;
        right--;
    }
    
    return true;
}
```

### 3. Longest Substring Without Repeating Characters
**Problem**: Find length of longest substring without repeating characters.
```java
public int lengthOfLongestSubstring(String s) {
    Set<Character> set = new HashSet<>();
    int left = 0, maxLength = 0;
    
    for (int right = 0; right < s.length(); right++) {
        while (set.contains(s.charAt(right))) {
            set.remove(s.charAt(left));
            left++;
        }
        set.add(s.charAt(right));
        maxLength = Math.max(maxLength, right - left + 1);
    }
    
    return maxLength;
}
```

### 4. Group Anagrams
**Problem**: Group strings that are anagrams of each other.
```java
public List<List<String>> groupAnagrams(String[] strs) {
    Map<String, List<String>> map = new HashMap<>();
    
    for (String str : strs) {
        char[] chars = str.toCharArray();
        Arrays.sort(chars);
        String key = String.valueOf(chars);
        
        map.computeIfAbsent(key, k -> new ArrayList<>()).add(str);
    }
    
    return new ArrayList<>(map.values());
}
```

### 5. Valid Parentheses
**Problem**: Check if parentheses are valid and properly closed.
```java
public boolean isValid(String s) {
    Stack<Character> stack = new Stack<>();
    Map<Character, Character> mapping = new HashMap<>();
    mapping.put(')', '(');
    mapping.put('}', '{');
    mapping.put(']', '[');
    
    for (char c : s.toCharArray()) {
        if (mapping.containsKey(c)) {
            if (stack.isEmpty() || stack.pop() != mapping.get(c)) {
                return false;
            }
        } else {
            stack.push(c);
        }
    }
    
    return stack.isEmpty();
}
```

### 6. Longest Palindromic Substring
**Problem**: Find the longest palindromic substring.
```java
public String longestPalindrome(String s) {
    if (s == null || s.length() < 2) {
        return s;
    }
    
    int start = 0;
    int maxLen = 1;
    
    for (int i = 0; i < s.length(); i++) {
        // Check for odd length palindromes
        int len1 = expandAroundCenter(s, i, i);
        // Check for even length palindromes
        int len2 = expandAroundCenter(s, i, i + 1);
        
        int len = Math.max(len1, len2);
        if (len > maxLen) {
            maxLen = len;
            start = i - (len - 1) / 2;
        }
    }
    
    return s.substring(start, start + maxLen);
}

private int expandAroundCenter(String s, int left, int right) {
    while (left >= 0 && right < s.length() && s.charAt(left) == s.charAt(right)) {
        left--;
        right++;
    }
    return right - left - 1;
}
```

### 7. String to Integer (atoi)
**Problem**: Convert string to integer with overflow handling.
```java
public int myAtoi(String s) {
    if (s == null || s.length() == 0) return 0;
    
    int i = 0;
    int sign = 1;
    int result = 0;
    
    // Skip whitespace
    while (i < s.length() && s.charAt(i) == ' ') {
        i++;
    }
    
    // Handle sign
    if (i < s.length() && (s.charAt(i) == '+' || s.charAt(i) == '-')) {
        sign = s.charAt(i) == '-' ? -1 : 1;
        i++;
    }
    
    // Convert digits
    while (i < s.length() && Character.isDigit(s.charAt(i))) {
        int digit = s.charAt(i) - '0';
        
        // Check overflow
        if (result > (Integer.MAX_VALUE - digit) / 10) {
            return sign == 1 ? Integer.MAX_VALUE : Integer.MIN_VALUE;
        }
        
        result = result * 10 + digit;
        i++;
    }
    
    return result * sign;
}
```

### 8. Implement strStr()
**Problem**: Find first occurrence of needle in haystack.
```java
public int strStr(String haystack, String needle) {
    if (needle.length() == 0) return 0;
    
    for (int i = 0; i <= haystack.length() - needle.length(); i++) {
        if (haystack.substring(i, i + needle.length()).equals(needle)) {
            return i;
        }
    }
    
    return -1;
}
```

### 9. Longest Common Prefix
**Problem**: Find longest common prefix among array of strings.
```java
public String longestCommonPrefix(String[] strs) {
    if (strs == null || strs.length == 0) {
        return "";
    }
    
    String prefix = strs[0];
    
    for (int i = 1; i < strs.length; i++) {
        while (strs[i].indexOf(prefix) != 0) {
            prefix = prefix.substring(0, prefix.length() - 1);
            if (prefix.isEmpty()) {
                return "";
            }
        }
    }
    
    return prefix;
}
```

### 10. Reverse String
**Problem**: Reverse string in-place.
```java
public void reverseString(char[] s) {
    int left = 0;
    int right = s.length - 1;
    
    while (left < right) {
        char temp = s[left];
        s[left] = s[right];
        s[right] = temp;
        left++;
        right--;
    }
}
```

### 11. Reverse Words in a String
**Problem**: Reverse words in string, removing extra spaces.
```java
public String reverseWords(String s) {
    String[] words = s.trim().split("\\s+");
    StringBuilder sb = new StringBuilder();
    
    for (int i = words.length - 1; i >= 0; i--) {
        sb.append(words[i]);
        if (i > 0) {
            sb.append(" ");
        }
    }
    
    return sb.toString();
}
```

### 12. Add Binary
**Problem**: Add two binary strings.
```java
public String addBinary(String a, String b) {
    StringBuilder sb = new StringBuilder();
    int i = a.length() - 1;
    int j = b.length() - 1;
    int carry = 0;
    
    while (i >= 0 || j >= 0 || carry > 0) {
        int sum = carry;
        
        if (i >= 0) {
            sum += a.charAt(i--) - '0';
        }
        
        if (j >= 0) {
            sum += b.charAt(j--) - '0';
        }
        
        sb.append(sum % 2);
        carry = sum / 2;
    }
    
    return sb.reverse().toString();
}
```

### 13. Multiply Strings
**Problem**: Multiply two non-negative integers represented as strings.
```java
public String multiply(String num1, String num2) {
    if (num1.equals("0") || num2.equals("0")) {
        return "0";
    }
    
    int m = num1.length();
    int n = num2.length();
    int[] result = new int[m + n];
    
    for (int i = m - 1; i >= 0; i--) {
        for (int j = n - 1; j >= 0; j--) {
            int mul = (num1.charAt(i) - '0') * (num2.charAt(j) - '0');
            int p1 = i + j;
            int p2 = i + j + 1;
            int sum = mul + result[p2];
            
            result[p2] = sum % 10;
            result[p1] += sum / 10;
        }
    }
    
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < result.length; i++) {
        if (!(sb.length() == 0 && result[i] == 0)) {
            sb.append(result[i]);
        }
    }
    
    return sb.length() == 0 ? "0" : sb.toString();
}
```

### 14. Compare Version Numbers
**Problem**: Compare two version numbers.
```java
public int compareVersion(String version1, String version2) {
    String[] v1 = version1.split("\\.");
    String[] v2 = version2.split("\\.");
    
    int maxLength = Math.max(v1.length, v2.length);
    
    for (int i = 0; i < maxLength; i++) {
        int num1 = i < v1.length ? Integer.parseInt(v1[i]) : 0;
        int num2 = i < v2.length ? Integer.parseInt(v2[i]) : 0;
        
        if (num1 < num2) {
            return -1;
        } else if (num1 > num2) {
            return 1;
        }
    }
    
    return 0;
}
```

### 15. Palindromic Substrings
**Problem**: Count palindromic substrings.
```java
public int countSubstrings(String s) {
    int count = 0;
    
    for (int i = 0; i < s.length(); i++) {
        // Count odd length palindromes
        count += expandAroundCenter(s, i, i);
        // Count even length palindromes
        count += expandAroundCenter(s, i, i + 1);
    }
    
    return count;
}

private int expandAroundCenter(String s, int left, int right) {
    int count = 0;
    
    while (left >= 0 && right < s.length() && s.charAt(left) == s.charAt(right)) {
        count++;
        left--;
        right++;
    }
    
    return count;
}
```

### 16. Minimum Window Substring
**Problem**: Find minimum window substring containing all characters of t.
```java
public String minWindow(String s, String t) {
    if (s.length() < t.length()) return "";
    
    Map<Character, Integer> targetCount = new HashMap<>();
    for (char c : t.toCharArray()) {
        targetCount.put(c, targetCount.getOrDefault(c, 0) + 1);
    }
    
    int left = 0, minLen = Integer.MAX_VALUE, minStart = 0;
    int matched = 0;
    Map<Character, Integer> windowCount = new HashMap<>();
    
    for (int right = 0; right < s.length(); right++) {
        char rightChar = s.charAt(right);
        windowCount.put(rightChar, windowCount.getOrDefault(rightChar, 0) + 1);
        
        if (targetCount.containsKey(rightChar) && 
            windowCount.get(rightChar).intValue() == targetCount.get(rightChar).intValue()) {
            matched++;
        }
        
        while (matched == targetCount.size()) {
            if (right - left + 1 < minLen) {
                minLen = right - left + 1;
                minStart = left;
            }
            
            char leftChar = s.charAt(left);
            windowCount.put(leftChar, windowCount.get(leftChar) - 1);
            
            if (targetCount.containsKey(leftChar) && 
                windowCount.get(leftChar) < targetCount.get(leftChar)) {
                matched--;
            }
            
            left++;
        }
    }
    
    return minLen == Integer.MAX_VALUE ? "" : s.substring(minStart, minStart + minLen);
}
```

### 17. Letter Combinations of Phone Number
**Problem**: Generate all possible letter combinations from phone number.
```java
public List<String> letterCombinations(String digits) {
    List<String> result = new ArrayList<>();
    if (digits == null || digits.length() == 0) {
        return result;
    }
    
    String[] mapping = {
        "", "", "abc", "def", "ghi", "jkl", "mno", "pqrs", "tuv", "wxyz"
    };
    
    backtrack(result, new StringBuilder(), digits, 0, mapping);
    return result;
}

private void backtrack(List<String> result, StringBuilder current, 
                      String digits, int index, String[] mapping) {
    if (index == digits.length()) {
        result.add(current.toString());
        return;
    }
    
    String letters = mapping[digits.charAt(index) - '0'];
    for (char c : letters.toCharArray()) {
        current.append(c);
        backtrack(result, current, digits, index + 1, mapping);
        current.deleteCharAt(current.length() - 1);
    }
}
```

### 18. Generate Parentheses
**Problem**: Generate all valid parentheses combinations.
```java
public List<String> generateParenthesis(int n) {
    List<String> result = new ArrayList<>();
    backtrack(result, "", 0, 0, n);
    return result;
}

private void backtrack(List<String> result, String current, int open, int close, int max) {
    if (current.length() == max * 2) {
        result.add(current);
        return;
    }
    
    if (open < max) {
        backtrack(result, current + "(", open + 1, close, max);
    }
    
    if (close < open) {
        backtrack(result, current + ")", open, close + 1, max);
    }
}
```

### 19. Remove Invalid Parentheses
**Problem**: Remove minimum invalid parentheses to make string valid.
```java
public List<String> removeInvalidParentheses(String s) {
    List<String> result = new ArrayList<>();
    if (s == null) return result;
    
    Set<String> visited = new HashSet<>();
    Queue<String> queue = new LinkedList<>();
    
    queue.offer(s);
    visited.add(s);
    boolean found = false;
    
    while (!queue.isEmpty()) {
        String str = queue.poll();
        
        if (isValid(str)) {
            result.add(str);
            found = true;
        }
        
        if (found) continue;
        
        for (int i = 0; i < str.length(); i++) {
            if (str.charAt(i) != '(' && str.charAt(i) != ')') continue;
            
            String next = str.substring(0, i) + str.substring(i + 1);
            if (!visited.contains(next)) {
                visited.add(next);
                queue.offer(next);
            }
        }
    }
    
    return result;
}

private boolean isValid(String s) {
    int count = 0;
    for (char c : s.toCharArray()) {
        if (c == '(') count++;
        else if (c == ')') count--;
        if (count < 0) return false;
    }
    return count == 0;
}
```

### 20. Decode String
**Problem**: Decode string with pattern k[encoded_string].
```java
public String decodeString(String s) {
    Stack<Integer> countStack = new Stack<>();
    Stack<StringBuilder> stringStack = new Stack<>();
    StringBuilder current = new StringBuilder();
    int k = 0;
    
    for (char c : s.toCharArray()) {
        if (Character.isDigit(c)) {
            k = k * 10 + (c - '0');
        } else if (c == '[') {
            countStack.push(k);
            stringStack.push(current);
            current = new StringBuilder();
            k = 0;
        } else if (c == ']') {
            StringBuilder temp = current;
            current = stringStack.pop();
            int count = countStack.pop();
            for (int i = 0; i < count; i++) {
                current.append(temp);
            }
        } else {
            current.append(c);
        }
    }
    
    return current.toString();
}
```

### 21. Word Break
**Problem**: Check if string can be segmented using dictionary words.
```java
public boolean wordBreak(String s, List<String> wordDict) {
    Set<String> wordSet = new HashSet<>(wordDict);
    boolean[] dp = new boolean[s.length() + 1];
    dp[0] = true;
    
    for (int i = 1; i <= s.length(); i++) {
        for (int j = 0; j < i; j++) {
            if (dp[j] && wordSet.contains(s.substring(j, i))) {
                dp[i] = true;
                break;
            }
        }
    }
    
    return dp[s.length()];
}
```

### 22. Word Break II
**Problem**: Return all possible sentences from word break.
```java
public List<String> wordBreak(String s, List<String> wordDict) {
    Set<String> wordSet = new HashSet<>(wordDict);
    Map<String, List<String>> memo = new HashMap<>();
    return helper(s, wordSet, memo);
}

private List<String> helper(String s, Set<String> wordSet, Map<String, List<String>> memo) {
    if (memo.containsKey(s)) {
        return memo.get(s);
    }
    
    List<String> result = new ArrayList<>();
    
    if (s.length() == 0) {
        result.add("");
        return result;
    }
    
    for (int i = 1; i <= s.length(); i++) {
        String prefix = s.substring(0, i);
        if (wordSet.contains(prefix)) {
            List<String> suffixes = helper(s.substring(i), wordSet, memo);
            for (String suffix : suffixes) {
                result.add(prefix + (suffix.isEmpty() ? "" : " " + suffix));
            }
        }
    }
    
    memo.put(s, result);
    return result;
}
```

### 23. Edit Distance
**Problem**: Find minimum edit distance between two strings.
```java
public int minDistance(String word1, String word2) {
    int m = word1.length();
    int n = word2.length();
    int[][] dp = new int[m + 1][n + 1];
    
    // Initialize base cases
    for (int i = 0; i <= m; i++) {
        dp[i][0] = i;
    }
    for (int j = 0; j <= n; j++) {
        dp[0][j] = j;
    }
    
    for (int i = 1; i <= m; i++) {
        for (int j = 1; j <= n; j++) {
            if (word1.charAt(i - 1) == word2.charAt(j - 1)) {
                dp[i][j] = dp[i - 1][j - 1];
            } else {
                dp[i][j] = 1 + Math.min(dp[i - 1][j - 1], 
                                       Math.min(dp[i - 1][j], dp[i][j - 1]));
            }
        }
    }
    
    return dp[m][n];
}
```

### 24. Regular Expression Matching
**Problem**: Implement regular expression matching with '.' and '*'.
```java
public boolean isMatch(String s, String p) {
    int m = s.length();
    int n = p.length();
    boolean[][] dp = new boolean[m + 1][n + 1];
    
    dp[0][0] = true;
    
    // Handle patterns like a*, a*b*, a*b*c*
    for (int j = 2; j <= n; j++) {
        if (p.charAt(j - 1) == '*') {
            dp[0][j] = dp[0][j - 2];
        }
    }
    
    for (int i = 1; i <= m; i++) {
        for (int j = 1; j <= n; j++) {
            char sc = s.charAt(i - 1);
            char pc = p.charAt(j - 1);
            
            if (pc == '*') {
                dp[i][j] = dp[i][j - 2]; // Zero occurrences
                
                if (matches(sc, p.charAt(j - 2))) {
                    dp[i][j] = dp[i][j] || dp[i - 1][j]; // One or more occurrences
                }
            } else if (matches(sc, pc)) {
                dp[i][j] = dp[i - 1][j - 1];
            }
        }
    }
    
    return dp[m][n];
}

private boolean matches(char s, char p) {
    return p == '.' || s == p;
}
```

### 25. Wildcard Matching
**Problem**: Implement wildcard pattern matching with '?' and '*'.
```java
public boolean isMatch(String s, String p) {
    int m = s.length();
    int n = p.length();
    boolean[][] dp = new boolean[m + 1][n + 1];
    
    dp[0][0] = true;
    
    // Handle patterns starting with *
    for (int j = 1; j <= n; j++) {
        if (p.charAt(j - 1) == '*') {
            dp[0][j] = dp[0][j - 1];
        }
    }
    
    for (int i = 1; i <= m; i++) {
        for (int j = 1; j <= n; j++) {
            char sc = s.charAt(i - 1);
            char pc = p.charAt(j - 1);
            
            if (pc == '*') {
                dp[i][j] = dp[i - 1][j] || dp[i][j - 1];
            } else if (pc == '?' || sc == pc) {
                dp[i][j] = dp[i - 1][j - 1];
            }
        }
    }
    
    return dp[m][n];
}
```

### 26. Longest Repeating Character Replacement
**Problem**: Find longest substring with same characters after k replacements.
```java
public int characterReplacement(String s, int k) {
    int[] count = new int[26];
    int left = 0;
    int maxCount = 0;
    int maxLength = 0;
    
    for (int right = 0; right < s.length(); right++) {
        count[s.charAt(right) - 'A']++;
        maxCount = Math.max(maxCount, count[s.charAt(right) - 'A']);
        
        if (right - left + 1 - maxCount > k) {
            count[s.charAt(left) - 'A']--;
            left++;
        }
        
        maxLength = Math.max(maxLength, right - left + 1);
    }
    
    return maxLength;
}
```

### 27. Find All Anagrams in String
**Problem**: Find all start indices of anagrams of p in s.
```java
public List<Integer> findAnagrams(String s, String p) {
    List<Integer> result = new ArrayList<>();
    if (s.length() < p.length()) return result;
    
    int[] pCount = new int[26];
    int[] sCount = new int[26];
    
    // Count characters in p
    for (char c : p.toCharArray()) {
        pCount[c - 'a']++;
    }
    
    int windowSize = p.length();
    
    // Initialize window
    for (int i = 0; i < windowSize; i++) {
        sCount[s.charAt(i) - 'a']++;
    }
    
    if (Arrays.equals(pCount, sCount)) {
        result.add(0);
    }
    
    // Slide window
    for (int i = windowSize; i < s.length(); i++) {
        sCount[s.charAt(i) - 'a']++;
        sCount[s.charAt(i - windowSize) - 'a']--;
        
        if (Arrays.equals(pCount, sCount)) {
            result.add(i - windowSize + 1);
        }
    }
    
    return result;
}
```

### 28. Substring with Concatenation of All Words
**Problem**: Find all starting indices of concatenated substrings.
```java
public List<Integer> findSubstring(String s, String[] words) {
    List<Integer> result = new ArrayList<>();
    if (s == null || words == null || words.length == 0) return result;
    
    int wordLen = words[0].length();
    int totalLen = wordLen * words.length;
    
    if (s.length() < totalLen) return result;
    
    Map<String, Integer> wordCount = new HashMap<>();
    for (String word : words) {
        wordCount.put(word, wordCount.getOrDefault(word, 0) + 1);
    }
    
    for (int i = 0; i <= s.length() - totalLen; i++) {
        Map<String, Integer> seen = new HashMap<>();
        int j = 0;
        
        while (j < words.length) {
            String word = s.substring(i + j * wordLen, i + (j + 1) * wordLen);
            
            if (!wordCount.containsKey(word)) break;
            
            seen.put(word, seen.getOrDefault(word, 0) + 1);
            
            if (seen.get(word) > wordCount.get(word)) break;
            
            j++;
        }
        
        if (j == words.length) {
            result.add(i);
        }
    }
    
    return result;
}
```

### 29. Shortest Palindrome
**Problem**: Find shortest palindrome by adding characters to front.
```java
public String shortestPalindrome(String s) {
    if (s == null || s.length() <= 1) return s;
    
    String rev = new StringBuilder(s).reverse().toString();
    String combined = s + "#" + rev;
    
    int[] lps = computeLPS(combined);
    int overlap = lps[combined.length() - 1];
    
    return rev.substring(0, s.length() - overlap) + s;
}

private int[] computeLPS(String s) {
    int[] lps = new int[s.length()];
    int len = 0;
    int i = 1;
    
    while (i < s.length()) {
        if (s.charAt(i) == s.charAt(len)) {
            len++;
            lps[i] = len;
            i++;
        } else {
            if (len != 0) {
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

### 30. Valid Number
**Problem**: Validate if string represents a valid number.
```java
public boolean isNumber(String s) {
    s = s.trim();
    boolean pointSeen = false;
    boolean eSeen = false;
    boolean numberSeen = false;
    boolean numberAfterE = true;
    
    for (int i = 0; i < s.length(); i++) {
        char c = s.charAt(i);
        
        if ('0' <= c && c <= '9') {
            numberSeen = true;
            numberAfterE = true;
        } else if (c == '.') {
            if (eSeen || pointSeen) return false;
            pointSeen = true;
        } else if (c == 'e' || c == 'E') {
            if (eSeen || !numberSeen) return false;
            numberAfterE = false;
            eSeen = true;
        } else if (c == '-' || c == '+') {
            if (i != 0 && s.charAt(i - 1) != 'e' && s.charAt(i - 1) != 'E') {
                return false;
            }
        } else {
            return false;
        }
    }
    
    return numberSeen && numberAfterE;
}
```

---

## Linked Lists

### 1. Reverse Linked List
**Problem**: Reverse a singly linked list.
```java
class ListNode {
    int val;
    ListNode next;
    ListNode() {}
    ListNode(int val) { this.val = val; }
    ListNode(int val, ListNode next) { this.val = val; this.next = next; }
}

public ListNode reverseList(ListNode head) {
    ListNode prev = null;
    ListNode current = head;
    
    while (current != null) {
        ListNode nextTemp = current.next;
        current.next = prev;
        prev = current;
        current = nextTemp;
    }
    
    return prev;
}
```

### 2. Merge Two Sorted Lists
**Problem**: Merge two sorted linked lists.
```java
public ListNode mergeTwoLists(ListNode list1, ListNode list2) {
    ListNode dummy = new ListNode(0);
    ListNode current = dummy;
    
    while (list1 != null && list2 != null) {
        if (list1.val <= list2.val) {
            current.next = list1;
            list1 = list1.next;
        } else {
            current.next = list2;
            list2 = list2.next;
        }
        current = current.next;
    }
    
    current.next = (list1 != null) ? list1 : list2;
    
    return dummy.next;
}
```

### 3. Detect Cycle in Linked List
**Problem**: Detect if linked list has a cycle.
```java
public boolean hasCycle(ListNode head) {
    if (head == null || head.next == null) {
        return false;
    }
    
    ListNode slow = head;
    ListNode fast = head.next;
    
    while (slow != fast) {
        if (fast == null || fast.next == null) {
            return false;
        }
        slow = slow.next;
        fast = fast.next.next;
    }
    
    return true;
}
```

### 4. Remove Nth Node From End
**Problem**: Remove the nth node from the end of linked list.
```java
public ListNode removeNthFromEnd(ListNode head, int n) {
    ListNode dummy = new ListNode(0);
    dummy.next = head;
    ListNode first = dummy;
    ListNode second = dummy;
    
    // Move first pointer n+1 steps ahead
    for (int i = 0; i <= n; i++) {
        first = first.next;
    }
    
    // Move both pointers until first reaches end
    while (first != null) {
        first = first.next;
        second = second.next;
    }
    
    second.next = second.next.next;
    return dummy.next;
}
```

### 5. Middle of Linked List
**Problem**: Find the middle node of linked list.
```java
public ListNode middleNode(ListNode head) {
    ListNode slow = head;
    ListNode fast = head;
    
    while (fast != null && fast.next != null) {
        slow = slow.next;
        fast = fast.next.next;
    }
    
    return slow;
}
```

---

## Stacks and Queues

### 1. Implement Stack using Arrays
```java
class MyStack {
    private int[] stack;
    private int top;
    private int capacity;
    
    public MyStack(int size) {
        stack = new int[size];
        capacity = size;
        top = -1;
    }
    
    public void push(int item) {
        if (isFull()) {
            throw new RuntimeException("Stack Overflow");
        }
        stack[++top] = item;
    }
    
    public int pop() {
        if (isEmpty()) {
            throw new RuntimeException("Stack Underflow");
        }
        return stack[top--];
    }
    
    public int peek() {
        if (isEmpty()) {
            throw new RuntimeException("Stack is empty");
        }
        return stack[top];
    }
    
    public boolean isEmpty() {
        return top == -1;
    }
    
    public boolean isFull() {
        return top == capacity - 1;
    }
}
```

### 2. Implement Queue using Arrays
```java
class MyQueue {
    private int[] queue;
    private int front;
    private int rear;
    private int size;
    private int capacity;
    
    public MyQueue(int capacity) {
        this.capacity = capacity;
        queue = new int[capacity];
        front = 0;
        rear = -1;
        size = 0;
    }
    
    public void enqueue(int item) {
        if (isFull()) {
            throw new RuntimeException("Queue is full");
        }
        rear = (rear + 1) % capacity;
        queue[rear] = item;
        size++;
    }
    
    public int dequeue() {
        if (isEmpty()) {
            throw new RuntimeException("Queue is empty");
        }
        int item = queue[front];
        front = (front + 1) % capacity;
        size--;
        return item;
    }
    
    public boolean isEmpty() {
        return size == 0;
    }
    
    public boolean isFull() {
        return size == capacity;
    }
}
```

### 3. Next Greater Element
**Problem**: Find next greater element for each element in array.
```java
public int[] nextGreaterElement(int[] nums) {
    int n = nums.length;
    int[] result = new int[n];
    Stack<Integer> stack = new Stack<>();
    
    // Initialize result with -1
    Arrays.fill(result, -1);
    
    for (int i = 0; i < n; i++) {
        while (!stack.isEmpty() && nums[stack.peek()] < nums[i]) {
            result[stack.pop()] = nums[i];
        }
        stack.push(i);
    }
    
    return result;
}
```

### 4. Largest Rectangle in Histogram
**Problem**: Find area of largest rectangle in histogram.
```java
public int largestRectangleArea(int[] heights) {
    Stack<Integer> stack = new Stack<>();
    int maxArea = 0;
    int index = 0;
    
    while (index < heights.length) {
        if (stack.isEmpty() || heights[index] >= heights[stack.peek()]) {
            stack.push(index++);
        } else {
            int top = stack.pop();
            int area = heights[top] * (stack.isEmpty() ? index : index - stack.peek() - 1);
            maxArea = Math.max(maxArea, area);
        }
    }
    
    while (!stack.isEmpty()) {
        int top = stack.pop();
        int area = heights[top] * (stack.isEmpty() ? index : index - stack.peek() - 1);
        maxArea = Math.max(maxArea, area);
    }
    
    return maxArea;
}
```

---

## Trees

### 1. Binary Tree Node Definition
```java
class TreeNode {
    int val;
    TreeNode left;
    TreeNode right;
    TreeNode() {}
    TreeNode(int val) { this.val = val; }
    TreeNode(int val, TreeNode left, TreeNode right) {
        this.val = val;
        this.left = left;
        this.right = right;
    }
}
```

### 2. Binary Tree Traversals
```java
// Inorder Traversal (Left, Root, Right)
public List<Integer> inorderTraversal(TreeNode root) {
    List<Integer> result = new ArrayList<>();
    inorderHelper(root, result);
    return result;
}

private void inorderHelper(TreeNode node, List<Integer> result) {
    if (node != null) {
        inorderHelper(node.left, result);
        result.add(node.val);
        inorderHelper(node.right, result);
    }
}

// Preorder Traversal (Root, Left, Right)
public List<Integer> preorderTraversal(TreeNode root) {
    List<Integer> result = new ArrayList<>();
    preorderHelper(root, result);
    return result;
}

private void preorderHelper(TreeNode node, List<Integer> result) {
    if (node != null) {
        result.add(node.val);
        preorderHelper(node.left, result);
        preorderHelper(node.right, result);
    }
}

// Postorder Traversal (Left, Right, Root)
public List<Integer> postorderTraversal(TreeNode root) {
    List<Integer> result = new ArrayList<>();
    postorderHelper(root, result);
    return result;
}

private void postorderHelper(TreeNode node, List<Integer> result) {
    if (node != null) {
        postorderHelper(node.left, result);
        postorderHelper(node.right, result);
        result.add(node.val);
    }
}
```

### 3. Level Order Traversal (BFS)
```java
public List<List<Integer>> levelOrder(TreeNode root) {
    List<List<Integer>> result = new ArrayList<>();
    if (root == null) return result;
    
    Queue<TreeNode> queue = new LinkedList<>();
    queue.offer(root);
    
    while (!queue.isEmpty()) {
        int levelSize = queue.size();
        List<Integer> currentLevel = new ArrayList<>();
        
        for (int i = 0; i < levelSize; i++) {
            TreeNode node = queue.poll();
            currentLevel.add(node.val);
            
            if (node.left != null) queue.offer(node.left);
            if (node.right != null) queue.offer(node.right);
        }
        
        result.add(currentLevel);
    }
    
    return result;
}
```

### 4. Maximum Depth of Binary Tree
```java
public int maxDepth(TreeNode root) {
    if (root == null) {
        return 0;
    }
    
    int leftDepth = maxDepth(root.left);
    int rightDepth = maxDepth(root.right);
    
    return Math.max(leftDepth, rightDepth) + 1;
}
```

### 5. Validate Binary Search Tree
```java
public boolean isValidBST(TreeNode root) {
    return validate(root, Long.MIN_VALUE, Long.MAX_VALUE);
}

private boolean validate(TreeNode node, long minVal, long maxVal) {
    if (node == null) {
        return true;
    }
    
    if (node.val <= minVal || node.val >= maxVal) {
        return false;
    }
    
    return validate(node.left, minVal, node.val) && 
           validate(node.right, node.val, maxVal);
}
```

### 6. Lowest Common Ancestor
```java
public TreeNode lowestCommonAncestor(TreeNode root, TreeNode p, TreeNode q) {
    if (root == null || root == p || root == q) {
        return root;
    }
    
    TreeNode left = lowestCommonAncestor(root.left, p, q);
    TreeNode right = lowestCommonAncestor(root.right, p, q);
    
    if (left != null && right != null) {
        return root;
    }
    
    return left != null ? left : right;
}
```

---

## Graphs

### 1. Graph Representation
```java
// Adjacency List representation
class Graph {
    private int vertices;
    private List<List<Integer>> adjList;
    
    public Graph(int vertices) {
        this.vertices = vertices;
        adjList = new ArrayList<>();
        for (int i = 0; i < vertices; i++) {
            adjList.add(new ArrayList<>());
        }
    }
    
    public void addEdge(int src, int dest) {
        adjList.get(src).add(dest);
        adjList.get(dest).add(src); // For undirected graph
    }
    
    public List<Integer> getNeighbors(int vertex) {
        return adjList.get(vertex);
    }
}
```

### 2. Depth-First Search (DFS)
```java
public void dfs(Graph graph, int startVertex) {
    boolean[] visited = new boolean[graph.vertices];
    dfsUtil(graph, startVertex, visited);
}

private void dfsUtil(Graph graph, int vertex, boolean[] visited) {
    visited[vertex] = true;
    System.out.print(vertex + " ");
    
    for (int neighbor : graph.getNeighbors(vertex)) {
        if (!visited[neighbor]) {
            dfsUtil(graph, neighbor, visited);
        }
    }
}
```

### 3. Breadth-First Search (BFS)
```java
public void bfs(Graph graph, int startVertex) {
    boolean[] visited = new boolean[graph.vertices];
    Queue<Integer> queue = new LinkedList<>();
    
    visited[startVertex] = true;
    queue.offer(startVertex);
    
    while (!queue.isEmpty()) {
        int vertex = queue.poll();
        System.out.print(vertex + " ");
        
        for (int neighbor : graph.getNeighbors(vertex)) {
            if (!visited[neighbor]) {
                visited[neighbor] = true;
                queue.offer(neighbor);
            }
        }
    }
}
```

### 4. Detect Cycle in Undirected Graph
```java
public boolean hasCycle(Graph graph) {
    boolean[] visited = new boolean[graph.vertices];
    
    for (int i = 0; i < graph.vertices; i++) {
        if (!visited[i]) {
            if (hasCycleUtil(graph, i, visited, -1)) {
                return true;
            }
        }
    }
    
    return false;
}

private boolean hasCycleUtil(Graph graph, int vertex, boolean[] visited, int parent) {
    visited[vertex] = true;
    
    for (int neighbor : graph.getNeighbors(vertex)) {
        if (!visited[neighbor]) {
            if (hasCycleUtil(graph, neighbor, visited, vertex)) {
                return true;
            }
        } else if (neighbor != parent) {
            return true;
        }
    }
    
    return false;
}
```

### 5. Topological Sort
```java
public List<Integer> topologicalSort(Graph graph) {
    Stack<Integer> stack = new Stack<>();
    boolean[] visited = new boolean[graph.vertices];
    
    for (int i = 0; i < graph.vertices; i++) {
        if (!visited[i]) {
            topologicalSortUtil(graph, i, visited, stack);
        }
    }
    
    List<Integer> result = new ArrayList<>();
    while (!stack.isEmpty()) {
        result.add(stack.pop());
    }
    
    return result;
}

private void topologicalSortUtil(Graph graph, int vertex, boolean[] visited, Stack<Integer> stack) {
    visited[vertex] = true;
    
    for (int neighbor : graph.getNeighbors(vertex)) {
        if (!visited[neighbor]) {
            topologicalSortUtil(graph, neighbor, visited, stack);
        }
    }
    
    stack.push(vertex);
}
```

---

## Dynamic Programming

### 1. Fibonacci Sequence
```java
// Memoization approach
public int fibonacci(int n) {
    int[] memo = new int[n + 1];
    Arrays.fill(memo, -1);
    return fibHelper(n, memo);
}

private int fibHelper(int n, int[] memo) {
    if (n <= 1) return n;
    
    if (memo[n] != -1) return memo[n];
    
    memo[n] = fibHelper(n - 1, memo) + fibHelper(n - 2, memo);
    return memo[n];
}

// Tabulation approach
public int fibonacciTabulation(int n) {
    if (n <= 1) return n;
    
    int[] dp = new int[n + 1];
    dp[0] = 0;
    dp[1] = 1;
    
    for (int i = 2; i <= n; i++) {
        dp[i] = dp[i - 1] + dp[i - 2];
    }
    
    return dp[n];
}
```

### 2. Climbing Stairs
**Problem**: Count ways to climb n stairs (1 or 2 steps at a time).
```java
public int climbStairs(int n) {
    if (n <= 2) return n;
    
    int prev2 = 1;
    int prev1 = 2;
    
    for (int i = 3; i <= n; i++) {
        int current = prev1 + prev2;
        prev2 = prev1;
        prev1 = current;
    }
    
    return prev1;
}
```

### 3. Coin Change Problem
**Problem**: Find minimum coins needed to make amount.
```java
public int coinChange(int[] coins, int amount) {
    int[] dp = new int[amount + 1];
    Arrays.fill(dp, amount + 1);
    dp[0] = 0;
    
    for (int i = 1; i <= amount; i++) {
        for (int coin : coins) {
            if (coin <= i) {
                dp[i] = Math.min(dp[i], dp[i - coin] + 1);
            }
        }
    }
    
    return dp[amount] > amount ? -1 : dp[amount];
}
```

### 4. Longest Common Subsequence
**Problem**: Find length of longest common subsequence.
```java
public int longestCommonSubsequence(String text1, String text2) {
    int m = text1.length();
    int n = text2.length();
    int[][] dp = new int[m + 1][n + 1];
    
    for (int i = 1; i <= m; i++) {
        for (int j = 1; j <= n; j++) {
            if (text1.charAt(i - 1) == text2.charAt(j - 1)) {
                dp[i][j] = dp[i - 1][j - 1] + 1;
            } else {
                dp[i][j] = Math.max(dp[i - 1][j], dp[i][j - 1]);
            }
        }
    }
    
    return dp[m][n];
}
```

### 5. 0/1 Knapsack Problem
**Problem**: Maximum value with weight constraint.
```java
public int knapsack(int[] weights, int[] values, int capacity) {
    int n = weights.length;
    int[][] dp = new int[n + 1][capacity + 1];
    
    for (int i = 1; i <= n; i++) {
        for (int w = 1; w <= capacity; w++) {
            if (weights[i - 1] <= w) {
                dp[i][w] = Math.max(
                    values[i - 1] + dp[i - 1][w - weights[i - 1]],
                    dp[i - 1][w]
                );
            } else {
                dp[i][w] = dp[i - 1][w];
            }
        }
    }
    
    return dp[n][capacity];
}
```

---

## Sorting and Searching

### 1. Quick Sort
```java
public void quickSort(int[] arr, int low, int high) {
    if (low < high) {
        int pi = partition(arr, low, high);
        quickSort(arr, low, pi - 1);
        quickSort(arr, pi + 1, high);
    }
}

private int partition(int[] arr, int low, int high) {
    int pivot = arr[high];
    int i = low - 1;
    
    for (int j = low; j < high; j++) {
        if (arr[j] < pivot) {
            i++;
            swap(arr, i, j);
        }
    }
    
    swap(arr, i + 1, high);
    return i + 1;
}

private void swap(int[] arr, int i, int j) {
    int temp = arr[i];
    arr[i] = arr[j];
    arr[j] = temp;
}
```

### 2. Merge Sort
```java
public void mergeSort(int[] arr, int left, int right) {
    if (left < right) {
        int mid = left + (right - left) / 2;
        
        mergeSort(arr, left, mid);
        mergeSort(arr, mid + 1, right);
        
        merge(arr, left, mid, right);
    }
}

private void merge(int[] arr, int left, int mid, int right) {
    int n1 = mid - left + 1;
    int n2 = right - mid;
    
    int[] leftArr = new int[n1];
    int[] rightArr = new int[n2];
    
    System.arraycopy(arr, left, leftArr, 0, n1);
    System.arraycopy(arr, mid + 1, rightArr, 0, n2);
    
    int i = 0, j = 0, k = left;
    
    while (i < n1 && j < n2) {
        if (leftArr[i] <= rightArr[j]) {
            arr[k] = leftArr[i];
            i++;
        } else {
            arr[k] = rightArr[j];
            j++;
        }
        k++;
    }
    
    while (i < n1) {
        arr[k] = leftArr[i];
        i++;
        k++;
    }
    
    while (j < n2) {
        arr[k] = rightArr[j];
        j++;
        k++;
    }
}
```

### 3. Binary Search
```java
public int binarySearch(int[] arr, int target) {
    int left = 0;
    int right = arr.length - 1;
    
    while (left <= right) {
        int mid = left + (right - left) / 2;
        
        if (arr[mid] == target) {
            return mid;
        } else if (arr[mid] < target) {
            left = mid + 1;
        } else {
            right = mid - 1;
        }
    }
    
    return -1; // Not found
}
```

### 4. Search in Rotated Sorted Array
```java
public int search(int[] nums, int target) {
    int left = 0;
    int right = nums.length - 1;
    
    while (left <= right) {
        int mid = left + (right - left) / 2;
        
        if (nums[mid] == target) {
            return mid;
        }
        
        if (nums[left] <= nums[mid]) {
            // Left half is sorted
            if (nums[left] <= target && target < nums[mid]) {
                right = mid - 1;
            } else {
                left = mid + 1;
            }
        } else {
            // Right half is sorted
            if (nums[mid] < target && target <= nums[right]) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }
    }
    
    return -1;
}
```

---

## Hashing

### 1. HashMap Implementation
```java
class MyHashMap<K, V> {
    private static final int INITIAL_CAPACITY = 16;
    private static final double LOAD_FACTOR = 0.75;
    
    private Node<K, V>[] buckets;
    private int size;
    private int capacity;
    
    static class Node<K, V> {
        K key;
        V value;
        Node<K, V> next;
        
        Node(K key, V value) {
            this.key = key;
            this.value = value;
        }
    }
    
    @SuppressWarnings("unchecked")
    public MyHashMap() {
        this.capacity = INITIAL_CAPACITY;
        this.buckets = new Node[capacity];
        this.size = 0;
    }
    
    private int hash(K key) {
        return key == null ? 0 : Math.abs(key.hashCode() % capacity);
    }
    
    public void put(K key, V value) {
        int index = hash(key);
        Node<K, V> head = buckets[index];
        
        while (head != null) {
            if (Objects.equals(head.key, key)) {
                head.value = value;
                return;
            }
            head = head.next;
        }
        
        Node<K, V> newNode = new Node<>(key, value);
        newNode.next = buckets[index];
        buckets[index] = newNode;
        size++;
        
        if (size >= capacity * LOAD_FACTOR) {
            resize();
        }
    }
    
    public V get(K key) {
        int index = hash(key);
        Node<K, V> head = buckets[index];
        
        while (head != null) {
            if (Objects.equals(head.key, key)) {
                return head.value;
            }
            head = head.next;
        }
        
        return null;
    }
    
    @SuppressWarnings("unchecked")
    private void resize() {
        Node<K, V>[] oldBuckets = buckets;
        capacity *= 2;
        buckets = new Node[capacity];
        size = 0;
        
        for (Node<K, V> head : oldBuckets) {
            while (head != null) {
                put(head.key, head.value);
                head = head.next;
            }
        }
    }
}
```

### 2. First Non-Repeating Character
```java
public int firstUniqChar(String s) {
    Map<Character, Integer> charCount = new HashMap<>();
    
    // Count frequency of each character
    for (char c : s.toCharArray()) {
        charCount.put(c, charCount.getOrDefault(c, 0) + 1);
    }
    
    // Find first character with count 1
    for (int i = 0; i < s.length(); i++) {
        if (charCount.get(s.charAt(i)) == 1) {
            return i;
        }
    }
    
    return -1;
}
```

---

## Heap

### 1. Min Heap Implementation
```java
class MinHeap {
    private int[] heap;
    private int size;
    private int capacity;
    
    public MinHeap(int capacity) {
        this.capacity = capacity;
        this.size = 0;
        this.heap = new int[capacity];
    }
    
    private int parent(int i) { return (i - 1) / 2; }
    private int leftChild(int i) { return 2 * i + 1; }
    private int rightChild(int i) { return 2 * i + 2; }
    
    public void insert(int key) {
        if (size >= capacity) {
            throw new RuntimeException("Heap overflow");
        }
        
        heap[size] = key;
        int current = size;
        size++;
        
        // Heapify up
        while (current != 0 && heap[current] < heap[parent(current)]) {
            swap(current, parent(current));
            current = parent(current);
        }
    }
    
    public int extractMin() {
        if (size <= 0) {
            throw new RuntimeException("Heap underflow");
        }
        
        if (size == 1) {
            size--;
            return heap[0];
        }
        
        int root = heap[0];
        heap[0] = heap[size - 1];
        size--;
        
        minHeapify(0);
        
        return root;
    }
    
    private void minHeapify(int i) {
        int left = leftChild(i);
        int right = rightChild(i);
        int smallest = i;
        
        if (left < size && heap[left] < heap[smallest]) {
            smallest = left;
        }
        
        if (right < size && heap[right] < heap[smallest]) {
            smallest = right;
        }
        
        if (smallest != i) {
            swap(i, smallest);
            minHeapify(smallest);
        }
    }
    
    private void swap(int i, int j) {
        int temp = heap[i];
        heap[i] = heap[j];
        heap[j] = temp;
    }
}
```

### 2. Kth Largest Element
```java
public int findKthLargest(int[] nums, int k) {
    PriorityQueue<Integer> minHeap = new PriorityQueue<>();
    
    for (int num : nums) {
        minHeap.offer(num);
        if (minHeap.size() > k) {
            minHeap.poll();
        }
    }
    
    return minHeap.peek();
}
```

---

## Backtracking

### 1. N-Queens Problem
```java
public List<List<String>> solveNQueens(int n) {
    List<List<String>> result = new ArrayList<>();
    char[][] board = new char[n][n];
    
    // Initialize board
    for (int i = 0; i < n; i++) {
        Arrays.fill(board[i], '.');
    }
    
    backtrack(board, 0, result);
    return result;
}

private void backtrack(char[][] board, int row, List<List<String>> result) {
    if (row == board.length) {
        result.add(construct(board));
        return;
    }
    
    for (int col = 0; col < board.length; col++) {
        if (isValid(board, row, col)) {
            board[row][col] = 'Q';
            backtrack(board, row + 1, result);
            board[row][col] = '.';
        }
    }
}

private boolean isValid(char[][] board, int row, int col) {
    int n = board.length;
    
    // Check column
    for (int i = 0; i < row; i++) {
        if (board[i][col] == 'Q') {
            return false;
        }
    }
    
    // Check diagonal
    for (int i = row - 1, j = col - 1; i >= 0 && j >= 0; i--, j--) {
        if (board[i][j] == 'Q') {
            return false;
        }
    }
    
    // Check anti-diagonal
    for (int i = row - 1, j = col + 1; i >= 0 && j < n; i--, j++) {
        if (board[i][j] == 'Q') {
            return false;
        }
    }
    
    return true;
}

private List<String> construct(char[][] board) {
    List<String> result = new ArrayList<>();
    for (char[] row : board) {
        result.add(new String(row));
    }
    return result;
}
```

### 2. Generate Parentheses
```java
public List<String> generateParenthesis(int n) {
    List<String> result = new ArrayList<>();
    backtrack(result, "", 0, 0, n);
    return result;
}

private void backtrack(List<String> result, String current, int open, int close, int max) {
    if (current.length() == max * 2) {
        result.add(current);
        return;
    }
    
    if (open < max) {
        backtrack(result, current + "(", open + 1, close, max);
    }
    
    if (close < open) {
        backtrack(result, current + ")", open, close + 1, max);
    }
}
```

---

## Greedy Algorithms

### 1. Activity Selection Problem
```java
class Activity {
    int start, finish;
    
    Activity(int start, int finish) {
        this.start = start;
        this.finish = finish;
    }
}

public int activitySelection(Activity[] activities) {
    // Sort by finish time
    Arrays.sort(activities, (a, b) -> a.finish - b.finish);
    
    int count = 1;
    int lastFinish = activities[0].finish;
    
    for (int i = 1; i < activities.length; i++) {
        if (activities[i].start >= lastFinish) {
            count++;
            lastFinish = activities[i].finish;
        }
    }
    
    return count;
}
```

### 2. Fractional Knapsack
```java
class Item {
    int value, weight;
    
    Item(int value, int weight) {
        this.value = value;
        this.weight = weight;
    }
}

public double fractionalKnapsack(Item[] items, int capacity) {
    // Sort by value/weight ratio in descending order
    Arrays.sort(items, (a, b) -> 
        Double.compare((double)b.value/b.weight, (double)a.value/a.weight));
    
    double totalValue = 0.0;
    int currentWeight = 0;
    
    for (Item item : items) {
        if (currentWeight + item.weight <= capacity) {
            currentWeight += item.weight;
            totalValue += item.value;
        } else {
            int remainingCapacity = capacity - currentWeight;
            totalValue += item.value * ((double)remainingCapacity / item.weight);
            break;
        }
    }
    
    return totalValue;
}
```

---

## Top 50 DSA Interview Questions

### Easy Level (1-20)

#### 1. Two Sum
**Problem**: Find two numbers that add up to target.
**Time Complexity**: O(n), **Space Complexity**: O(n)

#### 2. Valid Parentheses
**Problem**: Check if parentheses are balanced.
**Time Complexity**: O(n), **Space Complexity**: O(n)

#### 3. Merge Two Sorted Lists
**Problem**: Merge two sorted linked lists.
**Time Complexity**: O(m+n), **Space Complexity**: O(1)

#### 4. Maximum Subarray
**Problem**: Find contiguous subarray with maximum sum.
**Time Complexity**: O(n), **Space Complexity**: O(1)

#### 5. Climbing Stairs
**Problem**: Count ways to climb n stairs.
**Time Complexity**: O(n), **Space Complexity**: O(1)

#### 6. Best Time to Buy and Sell Stock
```java
public int maxProfit(int[] prices) {
    int minPrice = Integer.MAX_VALUE;
    int maxProfit = 0;
    
    for (int price : prices) {
        if (price < minPrice) {
            minPrice = price;
        } else if (price - minPrice > maxProfit) {
            maxProfit = price - minPrice;
        }
    }
    
    return maxProfit;
}
```

#### 7. Valid Palindrome
**Problem**: Check if string is palindrome ignoring case and non-alphanumeric.
**Time Complexity**: O(n), **Space Complexity**: O(1)

#### 8. Invert Binary Tree
```java
public TreeNode invertTree(TreeNode root) {
    if (root == null) return null;
    
    TreeNode temp = root.left;
    root.left = invertTree(root.right);
    root.right = invertTree(temp);
    
    return root;
}
```

#### 9. Valid Anagram
**Problem**: Check if two strings are anagrams.
**Time Complexity**: O(n), **Space Complexity**: O(1)

#### 10. Binary Search
**Problem**: Search target in sorted array.
**Time Complexity**: O(log n), **Space Complexity**: O(1)

### Medium Level (21-35)

#### 21. 3Sum
```java
public List<List<Integer>> threeSum(int[] nums) {
    List<List<Integer>> result = new ArrayList<>();
    Arrays.sort(nums);
    
    for (int i = 0; i < nums.length - 2; i++) {
        if (i > 0 && nums[i] == nums[i - 1]) continue;
        
        int left = i + 1;
        int right = nums.length - 1;
        
        while (left < right) {
            int sum = nums[i] + nums[left] + nums[right];
            
            if (sum == 0) {
                result.add(Arrays.asList(nums[i], nums[left], nums[right]));
                
                while (left < right && nums[left] == nums[left + 1]) left++;
                while (left < right && nums[right] == nums[right - 1]) right--;
                
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
```

#### 22. Container With Most Water
```java
public int maxArea(int[] height) {
    int left = 0;
    int right = height.length - 1;
    int maxArea = 0;
    
    while (left < right) {
        int area = Math.min(height[left], height[right]) * (right - left);
        maxArea = Math.max(maxArea, area);
        
        if (height[left] < height[right]) {
            left++;
        } else {
            right--;
        }
    }
    
    return maxArea;
}
```

#### 23. Longest Substring Without Repeating Characters
**Problem**: Find length of longest substring without repeating characters.
**Time Complexity**: O(n), **Space Complexity**: O(min(m,n))

#### 24. Add Two Numbers (Linked List)
```java
public ListNode addTwoNumbers(ListNode l1, ListNode l2) {
    ListNode dummy = new ListNode(0);
    ListNode current = dummy;
    int carry = 0;
    
    while (l1 != null || l2 != null || carry != 0) {
        int sum = carry;
        
        if (l1 != null) {
            sum += l1.val;
            l1 = l1.next;
        }
        
        if (l2 != null) {
            sum += l2.val;
            l2 = l2.next;
        }
        
        carry = sum / 10;
        current.next = new ListNode(sum % 10);
        current = current.next;
    }
    
    return dummy.next;
}
```

#### 25. Group Anagrams
**Problem**: Group strings that are anagrams.
**Time Complexity**: O(n * k log k), **Space Complexity**: O(n * k)

### Hard Level (36-50)

#### 36. Median of Two Sorted Arrays
```java
public double findMedianSortedArrays(int[] nums1, int[] nums2) {
    if (nums1.length > nums2.length) {
        return findMedianSortedArrays(nums2, nums1);
    }
    
    int x = nums1.length;
    int y = nums2.length;
    int low = 0;
    int high = x;
    
    while (low <= high) {
        int cutX = (low + high) / 2;
        int cutY = (x + y + 1) / 2 - cutX;
        
        int maxLeftX = (cutX == 0) ? Integer.MIN_VALUE : nums1[cutX - 1];
        int minRightX = (cutX == x) ? Integer.MAX_VALUE : nums1[cutX];
        
        int maxLeftY = (cutY == 0) ? Integer.MIN_VALUE : nums2[cutY - 1];
        int minRightY = (cutY == y) ? Integer.MAX_VALUE : nums2[cutY];
        
        if (maxLeftX <= minRightY && maxLeftY <= minRightX) {
            if ((x + y) % 2 == 0) {
                return ((double)Math.max(maxLeftX, maxLeftY) + 
                        Math.min(minRightX, minRightY)) / 2;
            } else {
                return (double)Math.max(maxLeftX, maxLeftY);
            }
        } else if (maxLeftX > minRightY) {
            high = cutX - 1;
        } else {
            low = cutX + 1;
        }
    }
    
    return 1.0;
}
```

#### 37. Trapping Rain Water
```java
public int trap(int[] height) {
    if (height == null || height.length == 0) {
        return 0;
    }
    
    int left = 0;
    int right = height.length - 1;
    int leftMax = 0;
    int rightMax = 0;
    int water = 0;
    
    while (left < right) {
        if (height[left] < height[right]) {
            if (height[left] >= leftMax) {
                leftMax = height[left];
            } else {
                water += leftMax - height[left];
            }
            left++;
        } else {
            if (height[right] >= rightMax) {
                rightMax = height[right];
            } else {
                water += rightMax - height[right];
            }
            right--;
        }
    }
    
    return water;
}
```

#### 38. Merge k Sorted Lists
```java
public ListNode mergeKLists(ListNode[] lists) {
    if (lists == null || lists.length == 0) {
        return null;
    }
    
    PriorityQueue<ListNode> pq = new PriorityQueue<>((a, b) -> a.val - b.val);
    
    for (ListNode list : lists) {
        if (list != null) {
            pq.offer(list);
        }
    }
    
    ListNode dummy = new ListNode(0);
    ListNode current = dummy;
    
    while (!pq.isEmpty()) {
        ListNode node = pq.poll();
        current.next = node;
        current = current.next;
        
        if (node.next != null) {
            pq.offer(node.next);
        }
    }
    
    return dummy.next;
}
```

#### 39. Sliding Window Maximum
```java
public int[] maxSlidingWindow(int[] nums, int k) {
    if (nums == null || nums.length == 0) {
        return new int[0];
    }
    
    int n = nums.length;
    int[] result = new int[n - k + 1];
    Deque<Integer> deque = new ArrayDeque<>();
    
    for (int i = 0; i < n; i++) {
        // Remove elements outside window
        while (!deque.isEmpty() && deque.peekFirst() < i - k + 1) {
            deque.pollFirst();
        }
        
        // Remove smaller elements
        while (!deque.isEmpty() && nums[deque.peekLast()] < nums[i]) {
            deque.pollLast();
        }
        
        deque.offerLast(i);
        
        if (i >= k - 1) {
            result[i - k + 1] = nums[deque.peekFirst()];
        }
    }
    
    return result;
}
```

#### 40. Word Ladder
```java
public int ladderLength(String beginWord, String endWord, List<String> wordList) {
    Set<String> wordSet = new HashSet<>(wordList);
    if (!wordSet.contains(endWord)) {
        return 0;
    }
    
    Queue<String> queue = new LinkedList<>();
    queue.offer(beginWord);
    int level = 1;
    
    while (!queue.isEmpty()) {
        int size = queue.size();
        
        for (int i = 0; i < size; i++) {
            String current = queue.poll();
            
            if (current.equals(endWord)) {
                return level;
            }
            
            char[] chars = current.toCharArray();
            
            for (int j = 0; j < chars.length; j++) {
                char original = chars[j];
                
                for (char c = 'a'; c <= 'z'; c++) {
                    if (c == original) continue;
                    
                    chars[j] = c;
                    String newWord = new String(chars);
                    
                    if (wordSet.contains(newWord)) {
                        queue.offer(newWord);
                        wordSet.remove(newWord);
                    }
                }
                
                chars[j] = original;
            }
        }
        
        level++;
    }
    
    return 0;
}
```

## Time and Space Complexity Cheat Sheet

### Common Data Structure Operations
| Data Structure | Access | Search | Insertion | Deletion |
|----------------|--------|--------|-----------|----------|
| Array          | O(1)   | O(n)   | O(n)      | O(n)     |
| Stack          | O(n)   | O(n)   | O(1)      | O(1)     |
| Queue          | O(n)   | O(n)   | O(1)      | O(1)     |
| Linked List    | O(n)   | O(n)   | O(1)      | O(1)     |
| Hash Table     | N/A    | O(1)   | O(1)      | O(1)     |
| Binary Search Tree | O(log n) | O(log n) | O(log n) | O(log n) |
| AVL Tree       | O(log n) | O(log n) | O(log n) | O(log n) |
| Binary Heap    | N/A    | O(n)   | O(log n)  | O(log n) |

### Sorting Algorithms
| Algorithm      | Best Case | Average Case | Worst Case | Space Complexity |
|----------------|-----------|--------------|------------|------------------|
| Quick Sort     | O(n log n)| O(n log n)   | O(n²)      | O(log n)         |
| Merge Sort     | O(n log n)| O(n log n)   | O(n log n) | O(n)             |
| Heap Sort      | O(n log n)| O(n log n)   | O(n log n) | O(1)             |
| Bubble Sort    | O(n)      | O(n²)        | O(n²)      | O(1)             |
| Selection Sort | O(n²)     | O(n²)        | O(n²)      | O(1)             |
| Insertion Sort | O(n)      | O(n²)        | O(n²)      | O(1)             |

## Interview Tips

### 1. Problem-Solving Approach
1. **Understand the problem**: Ask clarifying questions
2. **Think of examples**: Work through small examples
3. **Identify patterns**: Look for known algorithms/data structures
4. **Start with brute force**: Then optimize
5. **Code carefully**: Handle edge cases
6. **Test your solution**: Walk through examples

### 2. Common Patterns
- **Two Pointers**: Array problems, palindromes
- **Sliding Window**: Substring problems
- **Fast & Slow Pointers**: Cycle detection
- **Merge Intervals**: Overlapping intervals
- **Cyclic Sort**: Missing numbers
- **Tree BFS**: Level-order traversal
- **Tree DFS**: Path problems
- **Dynamic Programming**: Optimization problems

### 3. Edge Cases to Consider
- Empty input (null, empty array/string)
- Single element
- Duplicate elements
- Very large inputs
- Integer overflow
- Negative numbers

### 4. Space-Time Tradeoffs
- Can you solve it in O(1) space?
- Is there a faster solution using more space?
- Can you optimize using memoization?

## Practice Resources

### Online Platforms
- **LeetCode**: Most comprehensive for interview prep
- **HackerRank**: Good for beginners
- **CodeSignal**: Company-specific practice
- **InterviewBit**: Structured learning path

### Books
- "Cracking the Coding Interview" by Gayle McDowell
- "Elements of Programming Interviews in Java"
- "Algorithm Design Manual" by Steven Skiena

### Company-Specific Preparation
- **Google**: Focus on algorithms, system design
- **Amazon**: Leadership principles + coding
- **Microsoft**: Balanced technical + behavioral
- **Facebook/Meta**: Product sense + coding
- **Apple**: Attention to detail + optimization

---

*Good luck with your DSA interviews! Practice consistently and focus on understanding concepts rather than memorizing solutions.*
---


## Linked Lists

### 1. Reverse Linked List
**Problem**: Reverse a singly linked list.
```java
class ListNode {
    int val;
    ListNode next;
    ListNode() {}
    ListNode(int val) { this.val = val; }
    ListNode(int val, ListNode next) { this.val = val; this.next = next; }
}

public ListNode reverseList(ListNode head) {
    ListNode prev = null;
    ListNode current = head;
    
    while (current != null) {
        ListNode nextTemp = current.next;
        current.next = prev;
        prev = current;
        current = nextTemp;
    }
    
    return prev;
}
```

### 2. Merge Two Sorted Lists
**Problem**: Merge two sorted linked lists.
```java
public ListNode mergeTwoLists(ListNode list1, ListNode list2) {
    ListNode dummy = new ListNode(0);
    ListNode current = dummy;
    
    while (list1 != null && list2 != null) {
        if (list1.val <= list2.val) {
            current.next = list1;
            list1 = list1.next;
        } else {
            current.next = list2;
            list2 = list2.next;
        }
        current = current.next;
    }
    
    current.next = (list1 != null) ? list1 : list2;
    
    return dummy.next;
}
```

### 3. Detect Cycle in Linked List
**Problem**: Detect if linked list has a cycle.
```java
public boolean hasCycle(ListNode head) {
    if (head == null || head.next == null) {
        return false;
    }
    
    ListNode slow = head;
    ListNode fast = head.next;
    
    while (slow != fast) {
        if (fast == null || fast.next == null) {
            return false;
        }
        slow = slow.next;
        fast = fast.next.next;
    }
    
    return true;
}
```

### 4. Remove Nth Node From End
**Problem**: Remove the nth node from the end of linked list.
```java
public ListNode removeNthFromEnd(ListNode head, int n) {
    ListNode dummy = new ListNode(0);
    dummy.next = head;
    ListNode first = dummy;
    ListNode second = dummy;
    
    // Move first pointer n+1 steps ahead
    for (int i = 0; i <= n; i++) {
        first = first.next;
    }
    
    // Move both pointers until first reaches end
    while (first != null) {
        first = first.next;
        second = second.next;
    }
    
    second.next = second.next.next;
    return dummy.next;
}
```

### 5. Middle of Linked List
**Problem**: Find the middle node of linked list.
```java
public ListNode middleNode(ListNode head) {
    ListNode slow = head;
    ListNode fast = head;
    
    while (fast != null && fast.next != null) {
        slow = slow.next;
        fast = fast.next.next;
    }
    
    return slow;
}
```

### 6. Add Two Numbers
**Problem**: Add two numbers represented as linked lists.
```java
public ListNode addTwoNumbers(ListNode l1, ListNode l2) {
    ListNode dummy = new ListNode(0);
    ListNode current = dummy;
    int carry = 0;
    
    while (l1 != null || l2 != null || carry != 0) {
        int sum = carry;
        
        if (l1 != null) {
            sum += l1.val;
            l1 = l1.next;
        }
        
        if (l2 != null) {
            sum += l2.val;
            l2 = l2.next;
        }
        
        carry = sum / 10;
        current.next = new ListNode(sum % 10);
        current = current.next;
    }
    
    return dummy.next;
}
```

### 7. Remove Duplicates from Sorted List
**Problem**: Remove duplicates from sorted linked list.
```java
public ListNode deleteDuplicates(ListNode head) {
    ListNode current = head;
    
    while (current != null && current.next != null) {
        if (current.val == current.next.val) {
            current.next = current.next.next;
        } else {
            current = current.next;
        }
    }
    
    return head;
}
```

### 8. Remove Duplicates from Sorted List II
**Problem**: Remove all nodes with duplicate values.
```java
public ListNode deleteDuplicates(ListNode head) {
    ListNode dummy = new ListNode(0);
    dummy.next = head;
    ListNode prev = dummy;
    
    while (head != null) {
        if (head.next != null && head.val == head.next.val) {
            int val = head.val;
            while (head != null && head.val == val) {
                head = head.next;
            }
            prev.next = head;
        } else {
            prev = head;
            head = head.next;
        }
    }
    
    return dummy.next;
}
```

### 9. Intersection of Two Linked Lists
**Problem**: Find intersection point of two linked lists.
```java
public ListNode getIntersectionNode(ListNode headA, ListNode headB) {
    if (headA == null || headB == null) return null;
    
    ListNode pA = headA;
    ListNode pB = headB;
    
    while (pA != pB) {
        pA = (pA == null) ? headB : pA.next;
        pB = (pB == null) ? headA : pB.next;
    }
    
    return pA;
}
```

### 10. Palindrome Linked List
**Problem**: Check if linked list is palindrome.
```java
public boolean isPalindrome(ListNode head) {
    if (head == null || head.next == null) return true;
    
    // Find middle
    ListNode slow = head;
    ListNode fast = head;
    
    while (fast.next != null && fast.next.next != null) {
        slow = slow.next;
        fast = fast.next.next;
    }
    
    // Reverse second half
    ListNode secondHalf = reverseList(slow.next);
    
    // Compare
    ListNode firstHalf = head;
    while (secondHalf != null) {
        if (firstHalf.val != secondHalf.val) {
            return false;
        }
        firstHalf = firstHalf.next;
        secondHalf = secondHalf.next;
    }
    
    return true;
}

private ListNode reverseList(ListNode head) {
    ListNode prev = null;
    while (head != null) {
        ListNode next = head.next;
        head.next = prev;
        prev = head;
        head = next;
    }
    return prev;
}
```

### 11. Rotate List
**Problem**: Rotate list to the right by k places.
```java
public ListNode rotateRight(ListNode head, int k) {
    if (head == null || head.next == null || k == 0) {
        return head;
    }
    
    // Find length and make circular
    int length = 1;
    ListNode tail = head;
    while (tail.next != null) {
        tail = tail.next;
        length++;
    }
    tail.next = head;
    
    // Find new tail
    k = k % length;
    int stepsToNewTail = length - k;
    ListNode newTail = head;
    for (int i = 1; i < stepsToNewTail; i++) {
        newTail = newTail.next;
    }
    
    ListNode newHead = newTail.next;
    newTail.next = null;
    
    return newHead;
}
```

### 12. Swap Nodes in Pairs
**Problem**: Swap every two adjacent nodes.
```java
public ListNode swapPairs(ListNode head) {
    ListNode dummy = new ListNode(0);
    dummy.next = head;
    ListNode prev = dummy;
    
    while (prev.next != null && prev.next.next != null) {
        ListNode first = prev.next;
        ListNode second = prev.next.next;
        
        prev.next = second;
        first.next = second.next;
        second.next = first;
        
        prev = first;
    }
    
    return dummy.next;
}
```

### 13. Reverse Nodes in k-Group
**Problem**: Reverse nodes in groups of k.
```java
public ListNode reverseKGroup(ListNode head, int k) {
    if (head == null || k == 1) return head;
    
    // Check if we have k nodes
    ListNode curr = head;
    int count = 0;
    while (curr != null && count < k) {
        curr = curr.next;
        count++;
    }
    
    if (count == k) {
        curr = reverseKGroup(curr, k);
        
        while (count > 0) {
            ListNode next = head.next;
            head.next = curr;
            curr = head;
            head = next;
            count--;
        }
        head = curr;
    }
    
    return head;
}
```

### 14. Copy List with Random Pointer
**Problem**: Deep copy linked list with random pointers.
```java
class Node {
    int val;
    Node next;
    Node random;
    
    public Node(int val) {
        this.val = val;
        this.next = null;
        this.random = null;
    }
}

public Node copyRandomList(Node head) {
    if (head == null) return null;
    
    Map<Node, Node> map = new HashMap<>();
    
    // First pass: create all nodes
    Node curr = head;
    while (curr != null) {
        map.put(curr, new Node(curr.val));
        curr = curr.next;
    }
    
    // Second pass: set next and random pointers
    curr = head;
    while (curr != null) {
        map.get(curr).next = map.get(curr.next);
        map.get(curr).random = map.get(curr.random);
        curr = curr.next;
    }
    
    return map.get(head);
}
```

### 15. Flatten Multilevel Doubly Linked List
**Problem**: Flatten a multilevel doubly linked list.
```java
class Node {
    public int val;
    public Node prev;
    public Node next;
    public Node child;
}

public Node flatten(Node head) {
    if (head == null) return head;
    
    Stack<Node> stack = new Stack<>();
    Node curr = head;
    
    while (curr != null) {
        if (curr.child != null) {
            if (curr.next != null) {
                stack.push(curr.next);
            }
            
            curr.next = curr.child;
            curr.child.prev = curr;
            curr.child = null;
        }
        
        if (curr.next == null && !stack.isEmpty()) {
            Node next = stack.pop();
            curr.next = next;
            next.prev = curr;
        }
        
        curr = curr.next;
    }
    
    return head;
}
```

### 16. Sort List
**Problem**: Sort linked list using merge sort.
```java
public ListNode sortList(ListNode head) {
    if (head == null || head.next == null) {
        return head;
    }
    
    // Find middle
    ListNode mid = getMid(head);
    ListNode left = head;
    ListNode right = mid.next;
    mid.next = null;
    
    left = sortList(left);
    right = sortList(right);
    
    return merge(left, right);
}

private ListNode getMid(ListNode head) {
    ListNode slow = head;
    ListNode fast = head;
    ListNode prev = null;
    
    while (fast != null && fast.next != null) {
        prev = slow;
        slow = slow.next;
        fast = fast.next.next;
    }
    
    return prev;
}

private ListNode merge(ListNode l1, ListNode l2) {
    ListNode dummy = new ListNode(0);
    ListNode curr = dummy;
    
    while (l1 != null && l2 != null) {
        if (l1.val <= l2.val) {
            curr.next = l1;
            l1 = l1.next;
        } else {
            curr.next = l2;
            l2 = l2.next;
        }
        curr = curr.next;
    }
    
    curr.next = (l1 != null) ? l1 : l2;
    return dummy.next;
}
```

### 17. Merge k Sorted Lists
**Problem**: Merge k sorted linked lists.
```java
public ListNode mergeKLists(ListNode[] lists) {
    if (lists == null || lists.length == 0) {
        return null;
    }
    
    PriorityQueue<ListNode> pq = new PriorityQueue<>((a, b) -> a.val - b.val);
    
    for (ListNode list : lists) {
        if (list != null) {
            pq.offer(list);
        }
    }
    
    ListNode dummy = new ListNode(0);
    ListNode current = dummy;
    
    while (!pq.isEmpty()) {
        ListNode node = pq.poll();
        current.next = node;
        current = current.next;
        
        if (node.next != null) {
            pq.offer(node.next);
        }
    }
    
    return dummy.next;
}
```

### 18. Remove Elements
**Problem**: Remove all elements with given value.
```java
public ListNode removeElements(ListNode head, int val) {
    ListNode dummy = new ListNode(0);
    dummy.next = head;
    ListNode prev = dummy;
    ListNode curr = head;
    
    while (curr != null) {
        if (curr.val == val) {
            prev.next = curr.next;
        } else {
            prev = curr;
        }
        curr = curr.next;
    }
    
    return dummy.next;
}
```

### 19. Odd Even Linked List
**Problem**: Group odd and even positioned nodes together.
```java
public ListNode oddEvenList(ListNode head) {
    if (head == null || head.next == null) {
        return head;
    }
    
    ListNode odd = head;
    ListNode even = head.next;
    ListNode evenHead = even;
    
    while (even != null && even.next != null) {
        odd.next = even.next;
        odd = odd.next;
        even.next = odd.next;
        even = even.next;
    }
    
    odd.next = evenHead;
    return head;
}
```

### 20. Partition List
**Problem**: Partition list around value x.
```java
public ListNode partition(ListNode head, int x) {
    ListNode beforeHead = new ListNode(0);
    ListNode before = beforeHead;
    ListNode afterHead = new ListNode(0);
    ListNode after = afterHead;
    
    while (head != null) {
        if (head.val < x) {
            before.next = head;
            before = before.next;
        } else {
            after.next = head;
            after = after.next;
        }
        head = head.next;
    }
    
    after.next = null;
    before.next = afterHead.next;
    
    return beforeHead.next;
}
```

### 21. Reorder List
**Problem**: Reorder list to L0→Ln→L1→Ln-1→L2→Ln-2→...
```java
public void reorderList(ListNode head) {
    if (head == null || head.next == null) return;
    
    // Find middle
    ListNode slow = head;
    ListNode fast = head;
    
    while (fast.next != null && fast.next.next != null) {
        slow = slow.next;
        fast = fast.next.next;
    }
    
    // Reverse second half
    ListNode second = slow.next;
    slow.next = null;
    second = reverseList(second);
    
    // Merge two halves
    ListNode first = head;
    while (second != null) {
        ListNode temp1 = first.next;
        ListNode temp2 = second.next;
        
        first.next = second;
        second.next = temp1;
        
        first = temp1;
        second = temp2;
    }
}
```

### 22. Split Linked List in Parts
**Problem**: Split linked list into k consecutive parts.
```java
public ListNode[] splitListToParts(ListNode root, int k) {
    ListNode[] result = new ListNode[k];
    
    // Count length
    int length = 0;
    ListNode curr = root;
    while (curr != null) {
        length++;
        curr = curr.next;
    }
    
    int partSize = length / k;
    int extraNodes = length % k;
    
    curr = root;
    for (int i = 0; i < k && curr != null; i++) {
        result[i] = curr;
        int currentPartSize = partSize + (i < extraNodes ? 1 : 0);
        
        for (int j = 1; j < currentPartSize; j++) {
            curr = curr.next;
        }
        
        ListNode next = curr.next;
        curr.next = null;
        curr = next;
    }
    
    return result;
}
```

### 23. Next Greater Node in Linked List
**Problem**: Find next greater element for each node.
```java
public int[] nextLargerNodes(ListNode head) {
    List<Integer> values = new ArrayList<>();
    ListNode curr = head;
    
    while (curr != null) {
        values.add(curr.val);
        curr = curr.next;
    }
    
    int[] result = new int[values.size()];
    Stack<Integer> stack = new Stack<>();
    
    for (int i = 0; i < values.size(); i++) {
        while (!stack.isEmpty() && values.get(stack.peek()) < values.get(i)) {
            result[stack.pop()] = values.get(i);
        }
        stack.push(i);
    }
    
    return result;
}
```

### 24. Convert Binary Number to Integer
**Problem**: Convert binary number in linked list to integer.
```java
public int getDecimalValue(ListNode head) {
    int result = 0;
    
    while (head != null) {
        result = result * 2 + head.val;
        head = head.next;
    }
    
    return result;
}
```

### 25. Delete Node in Linked List
**Problem**: Delete node when only given access to that node.
```java
public void deleteNode(ListNode node) {
    node.val = node.next.val;
    node.next = node.next.next;
}
```

### 26. Linked List Cycle II
**Problem**: Find the start of the cycle in linked list.
```java
public ListNode detectCycle(ListNode head) {
    if (head == null || head.next == null) return null;
    
    ListNode slow = head;
    ListNode fast = head;
    
    // Detect cycle
    while (fast != null && fast.next != null) {
        slow = slow.next;
        fast = fast.next.next;
        
        if (slow == fast) {
            // Find start of cycle
            ListNode start = head;
            while (start != slow) {
                start = start.next;
                slow = slow.next;
            }
            return start;
        }
    }
    
    return null;
}
```

### 27. Remove Zero Sum Consecutive Nodes
**Problem**: Remove consecutive nodes that sum to zero.
```java
public ListNode removeZeroSumSublists(ListNode head) {
    ListNode dummy = new ListNode(0);
    dummy.next = head;
    
    Map<Integer, ListNode> prefixSumMap = new HashMap<>();
    int prefixSum = 0;
    
    for (ListNode curr = dummy; curr != null; curr = curr.next) {
        prefixSum += curr.val;
        prefixSumMap.put(prefixSum, curr);
    }
    
    prefixSum = 0;
    for (ListNode curr = dummy; curr != null; curr = curr.next) {
        prefixSum += curr.val;
        curr.next = prefixSumMap.get(prefixSum).next;
    }
    
    return dummy.next;
}
```

### 28. Add Two Numbers II
**Problem**: Add two numbers represented as linked lists (most significant digit first).
```java
public ListNode addTwoNumbers(ListNode l1, ListNode l2) {
    Stack<Integer> s1 = new Stack<>();
    Stack<Integer> s2 = new Stack<>();
    
    while (l1 != null) {
        s1.push(l1.val);
        l1 = l1.next;
    }
    
    while (l2 != null) {
        s2.push(l2.val);
        l2 = l2.next;
    }
    
    ListNode result = null;
    int carry = 0;
    
    while (!s1.isEmpty() || !s2.isEmpty() || carry != 0) {
        int sum = carry;
        
        if (!s1.isEmpty()) {
            sum += s1.pop();
        }
        
        if (!s2.isEmpty()) {
            sum += s2.pop();
        }
        
        ListNode node = new ListNode(sum % 10);
        node.next = result;
        result = node;
        
        carry = sum / 10;
    }
    
    return result;
}
```

### 29. Reverse Linked List II
**Problem**: Reverse linked list from position m to n.
```java
public ListNode reverseBetween(ListNode head, int left, int right) {
    if (head == null || left == right) return head;
    
    ListNode dummy = new ListNode(0);
    dummy.next = head;
    ListNode prev = dummy;
    
    // Move to position before left
    for (int i = 0; i < left - 1; i++) {
        prev = prev.next;
    }
    
    ListNode curr = prev.next;
    
    // Reverse from left to right
    for (int i = 0; i < right - left; i++) {
        ListNode next = curr.next;
        curr.next = next.next;
        next.next = prev.next;
        prev.next = next;
    }
    
    return dummy.next;
}
```

### 30. Design Linked List
**Problem**: Design your own linked list implementation.
```java
class MyLinkedList {
    class Node {
        int val;
        Node next;
        
        Node(int val) {
            this.val = val;
        }
    }
    
    private Node head;
    private int size;
    
    public MyLinkedList() {
        head = null;
        size = 0;
    }
    
    public int get(int index) {
        if (index < 0 || index >= size) return -1;
        
        Node curr = head;
        for (int i = 0; i < index; i++) {
            curr = curr.next;
        }
        
        return curr.val;
    }
    
    public void addAtHead(int val) {
        Node newNode = new Node(val);
        newNode.next = head;
        head = newNode;
        size++;
    }
    
    public void addAtTail(int val) {
        Node newNode = new Node(val);
        
        if (head == null) {
            head = newNode;
        } else {
            Node curr = head;
            while (curr.next != null) {
                curr = curr.next;
            }
            curr.next = newNode;
        }
        
        size++;
    }
    
    public void addAtIndex(int index, int val) {
        if (index > size) return;
        
        if (index <= 0) {
            addAtHead(val);
            return;
        }
        
        Node newNode = new Node(val);
        Node curr = head;
        
        for (int i = 0; i < index - 1; i++) {
            curr = curr.next;
        }
        
        newNode.next = curr.next;
        curr.next = newNode;
        size++;
    }
    
    public void deleteAtIndex(int index) {
        if (index < 0 || index >= size) return;
        
        if (index == 0) {
            head = head.next;
        } else {
            Node curr = head;
            for (int i = 0; i < index - 1; i++) {
                curr = curr.next;
            }
            curr.next = curr.next.next;
        }
        
        size--;
    }
}
```
---

## Stacks and Queues

### 1. Implement Stack using Arrays
```java
class MyStack {
    private int[] stack;
    private int top;
    private int capacity;
    
    public MyStack(int size) {
        stack = new int[size];
        capacity = size;
        top = -1;
    }
    
    public void push(int item) {
        if (isFull()) {
            throw new RuntimeException("Stack Overflow");
        }
        stack[++top] = item;
    }
    
    public int pop() {
        if (isEmpty()) {
            throw new RuntimeException("Stack Underflow");
        }
        return stack[top--];
    }
    
    public int peek() {
        if (isEmpty()) {
            throw new RuntimeException("Stack is empty");
        }
        return stack[top];
    }
    
    public boolean isEmpty() {
        return top == -1;
    }
    
    public boolean isFull() {
        return top == capacity - 1;
    }
}
```

### 2. Implement Queue using Arrays
```java
class MyQueue {
    private int[] queue;
    private int front;
    private int rear;
    private int size;
    private int capacity;
    
    public MyQueue(int capacity) {
        this.capacity = capacity;
        queue = new int[capacity];
        front = 0;
        rear = -1;
        size = 0;
    }
    
    public void enqueue(int item) {
        if (isFull()) {
            throw new RuntimeException("Queue is full");
        }
        rear = (rear + 1) % capacity;
        queue[rear] = item;
        size++;
    }
    
    public int dequeue() {
        if (isEmpty()) {
            throw new RuntimeException("Queue is empty");
        }
        int item = queue[front];
        front = (front + 1) % capacity;
        size--;
        return item;
    }
    
    public boolean isEmpty() {
        return size == 0;
    }
    
    public boolean isFull() {
        return size == capacity;
    }
}
```

### 3. Valid Parentheses
**Problem**: Check if parentheses are valid.
```java
public boolean isValid(String s) {
    Stack<Character> stack = new Stack<>();
    Map<Character, Character> mapping = new HashMap<>();
    mapping.put(')', '(');
    mapping.put('}', '{');
    mapping.put(']', '[');
    
    for (char c : s.toCharArray()) {
        if (mapping.containsKey(c)) {
            if (stack.isEmpty() || stack.pop() != mapping.get(c)) {
                return false;
            }
        } else {
            stack.push(c);
        }
    }
    
    return stack.isEmpty();
}
```

### 4. Min Stack
**Problem**: Design stack with getMin() in O(1).
```java
class MinStack {
    private Stack<Integer> stack;
    private Stack<Integer> minStack;
    
    public MinStack() {
        stack = new Stack<>();
        minStack = new Stack<>();
    }
    
    public void push(int val) {
        stack.push(val);
        if (minStack.isEmpty() || val <= minStack.peek()) {
            minStack.push(val);
        }
    }
    
    public void pop() {
        if (stack.pop().equals(minStack.peek())) {
            minStack.pop();
        }
    }
    
    public int top() {
        return stack.peek();
    }
    
    public int getMin() {
        return minStack.peek();
    }
}
```

### 5. Evaluate Reverse Polish Notation
**Problem**: Evaluate arithmetic expression in RPN.
```java
public int evalRPN(String[] tokens) {
    Stack<Integer> stack = new Stack<>();
    
    for (String token : tokens) {
        if (isOperator(token)) {
            int b = stack.pop();
            int a = stack.pop();
            stack.push(calculate(a, b, token));
        } else {
            stack.push(Integer.parseInt(token));
        }
    }
    
    return stack.pop();
}

private boolean isOperator(String token) {
    return token.equals("+") || token.equals("-") || 
           token.equals("*") || token.equals("/");
}

private int calculate(int a, int b, String operator) {
    switch (operator) {
        case "+": return a + b;
        case "-": return a - b;
        case "*": return a * b;
        case "/": return a / b;
        default: throw new IllegalArgumentException("Invalid operator");
    }
}
```

### 6. Next Greater Element I
**Problem**: Find next greater element for each element.
```java
public int[] nextGreaterElement(int[] nums1, int[] nums2) {
    Map<Integer, Integer> nextGreater = new HashMap<>();
    Stack<Integer> stack = new Stack<>();
    
    for (int num : nums2) {
        while (!stack.isEmpty() && stack.peek() < num) {
            nextGreater.put(stack.pop(), num);
        }
        stack.push(num);
    }
    
    int[] result = new int[nums1.length];
    for (int i = 0; i < nums1.length; i++) {
        result[i] = nextGreater.getOrDefault(nums1[i], -1);
    }
    
    return result;
}
```

### 7. Daily Temperatures
**Problem**: Find number of days until warmer temperature.
```java
public int[] dailyTemperatures(int[] temperatures) {
    int n = temperatures.length;
    int[] result = new int[n];
    Stack<Integer> stack = new Stack<>();
    
    for (int i = 0; i < n; i++) {
        while (!stack.isEmpty() && temperatures[i] > temperatures[stack.peek()]) {
            int index = stack.pop();
            result[index] = i - index;
        }
        stack.push(i);
    }
    
    return result;
}
```

### 8. Largest Rectangle in Histogram
**Problem**: Find area of largest rectangle in histogram.
```java
public int largestRectangleArea(int[] heights) {
    Stack<Integer> stack = new Stack<>();
    int maxArea = 0;
    int index = 0;
    
    while (index < heights.length) {
        if (stack.isEmpty() || heights[index] >= heights[stack.peek()]) {
            stack.push(index++);
        } else {
            int top = stack.pop();
            int area = heights[top] * (stack.isEmpty() ? index : index - stack.peek() - 1);
            maxArea = Math.max(maxArea, area);
        }
    }
    
    while (!stack.isEmpty()) {
        int top = stack.pop();
        int area = heights[top] * (stack.isEmpty() ? index : index - stack.peek() - 1);
        maxArea = Math.max(maxArea, area);
    }
    
    return maxArea;
}
```

### 9. Implement Queue using Stacks
**Problem**: Implement queue using two stacks.
```java
class MyQueue {
    private Stack<Integer> input;
    private Stack<Integer> output;
    
    public MyQueue() {
        input = new Stack<>();
        output = new Stack<>();
    }
    
    public void push(int x) {
        input.push(x);
    }
    
    public int pop() {
        peek();
        return output.pop();
    }
    
    public int peek() {
        if (output.isEmpty()) {
            while (!input.isEmpty()) {
                output.push(input.pop());
            }
        }
        return output.peek();
    }
    
    public boolean empty() {
        return input.isEmpty() && output.isEmpty();
    }
}
```

### 10. Implement Stack using Queues
**Problem**: Implement stack using queues.
```java
class MyStack {
    private Queue<Integer> queue;
    
    public MyStack() {
        queue = new LinkedList<>();
    }
    
    public void push(int x) {
        queue.offer(x);
        int size = queue.size();
        
        while (size > 1) {
            queue.offer(queue.poll());
            size--;
        }
    }
    
    public int pop() {
        return queue.poll();
    }
    
    public int top() {
        return queue.peek();
    }
    
    public boolean empty() {
        return queue.isEmpty();
    }
}
```

### 11. Sliding Window Maximum
**Problem**: Find maximum in each sliding window.
```java
public int[] maxSlidingWindow(int[] nums, int k) {
    if (nums == null || nums.length == 0) {
        return new int[0];
    }
    
    int n = nums.length;
    int[] result = new int[n - k + 1];
    Deque<Integer> deque = new ArrayDeque<>();
    
    for (int i = 0; i < n; i++) {
        // Remove elements outside window
        while (!deque.isEmpty() && deque.peekFirst() < i - k + 1) {
            deque.pollFirst();
        }
        
        // Remove smaller elements
        while (!deque.isEmpty() && nums[deque.peekLast()] < nums[i]) {
            deque.pollLast();
        }
        
        deque.offerLast(i);
        
        if (i >= k - 1) {
            result[i - k + 1] = nums[deque.peekFirst()];
        }
    }
    
    return result;
}
```

### 12. Basic Calculator
**Problem**: Implement basic calculator for +, -, (, ).
```java
public int calculate(String s) {
    Stack<Integer> stack = new Stack<>();
    int result = 0;
    int number = 0;
    int sign = 1;
    
    for (char c : s.toCharArray()) {
        if (Character.isDigit(c)) {
            number = number * 10 + (c - '0');
        } else if (c == '+') {
            result += sign * number;
            number = 0;
            sign = 1;
        } else if (c == '-') {
            result += sign * number;
            number = 0;
            sign = -1;
        } else if (c == '(') {
            stack.push(result);
            stack.push(sign);
            sign = 1;
            result = 0;
        } else if (c == ')') {
            result += sign * number;
            number = 0;
            result *= stack.pop();
            result += stack.pop();
        }
    }
    
    if (number != 0) {
        result += sign * number;
    }
    
    return result;
}
```

### 13. Basic Calculator II
**Problem**: Implement calculator for +, -, *, /.
```java
public int calculate(String s) {
    Stack<Integer> stack = new Stack<>();
    int number = 0;
    char operation = '+';
    
    for (int i = 0; i < s.length(); i++) {
        char c = s.charAt(i);
        
        if (Character.isDigit(c)) {
            number = number * 10 + (c - '0');
        }
        
        if (!Character.isDigit(c) && c != ' ' || i == s.length() - 1) {
            if (operation == '+') {
                stack.push(number);
            } else if (operation == '-') {
                stack.push(-number);
            } else if (operation == '*') {
                stack.push(stack.pop() * number);
            } else if (operation == '/') {
                stack.push(stack.pop() / number);
            }
            
            operation = c;
            number = 0;
        }
    }
    
    int result = 0;
    while (!stack.isEmpty()) {
        result += stack.pop();
    }
    
    return result;
}
```

### 14. Decode String
**Problem**: Decode string with pattern k[encoded_string].
```java
public String decodeString(String s) {
    Stack<Integer> countStack = new Stack<>();
    Stack<StringBuilder> stringStack = new Stack<>();
    StringBuilder current = new StringBuilder();
    int k = 0;
    
    for (char c : s.toCharArray()) {
        if (Character.isDigit(c)) {
            k = k * 10 + (c - '0');
        } else if (c == '[') {
            countStack.push(k);
            stringStack.push(current);
            current = new StringBuilder();
            k = 0;
        } else if (c == ']') {
            StringBuilder temp = current;
            current = stringStack.pop();
            int count = countStack.pop();
            for (int i = 0; i < count; i++) {
                current.append(temp);
            }
        } else {
            current.append(c);
        }
    }
    
    return current.toString();
}
```

### 15. Remove K Digits
**Problem**: Remove k digits to make smallest number.
```java
public String removeKdigits(String num, int k) {
    Stack<Character> stack = new Stack<>();
    
    for (char c : num.toCharArray()) {
        while (!stack.isEmpty() && k > 0 && stack.peek() > c) {
            stack.pop();
            k--;
        }
        stack.push(c);
    }
    
    // Remove remaining digits
    while (k > 0) {
        stack.pop();
        k--;
    }
    
    // Build result
    StringBuilder sb = new StringBuilder();
    while (!stack.isEmpty()) {
        sb.append(stack.pop());
    }
    
    sb.reverse();
    
    // Remove leading zeros
    while (sb.length() > 1 && sb.charAt(0) == '0') {
        sb.deleteCharAt(0);
    }
    
    return sb.length() == 0 ? "0" : sb.toString();
}
```

### 16. Asteroid Collision
**Problem**: Simulate asteroid collisions.
```java
public int[] asteroidCollision(int[] asteroids) {
    Stack<Integer> stack = new Stack<>();
    
    for (int asteroid : asteroids) {
        boolean exploded = false;
        
        while (!stack.isEmpty() && asteroid < 0 && stack.peek() > 0) {
            if (stack.peek() < -asteroid) {
                stack.pop();
                continue;
            } else if (stack.peek() == -asteroid) {
                stack.pop();
            }
            exploded = true;
            break;
        }
        
        if (!exploded) {
            stack.push(asteroid);
        }
    }
    
    int[] result = new int[stack.size()];
    for (int i = result.length - 1; i >= 0; i--) {
        result[i] = stack.pop();
    }
    
    return result;
}
```

### 17. Maximal Rectangle
**Problem**: Find largest rectangle in binary matrix.
```java
public int maximalRectangle(char[][] matrix) {
    if (matrix.length == 0) return 0;
    
    int maxArea = 0;
    int[] heights = new int[matrix[0].length];
    
    for (int i = 0; i < matrix.length; i++) {
        for (int j = 0; j < matrix[0].length; j++) {
            if (matrix[i][j] == '1') {
                heights[j]++;
            } else {
                heights[j] = 0;
            }
        }
        maxArea = Math.max(maxArea, largestRectangleArea(heights));
    }
    
    return maxArea;
}

private int largestRectangleArea(int[] heights) {
    Stack<Integer> stack = new Stack<>();
    int maxArea = 0;
    int index = 0;
    
    while (index < heights.length) {
        if (stack.isEmpty() || heights[index] >= heights[stack.peek()]) {
            stack.push(index++);
        } else {
            int top = stack.pop();
            int area = heights[top] * (stack.isEmpty() ? index : index - stack.peek() - 1);
            maxArea = Math.max(maxArea, area);
        }
    }
    
    while (!stack.isEmpty()) {
        int top = stack.pop();
        int area = heights[top] * (stack.isEmpty() ? index : index - stack.peek() - 1);
        maxArea = Math.max(maxArea, area);
    }
    
    return maxArea;
}
```

### 18. Trapping Rain Water
**Problem**: Calculate trapped rainwater using stack.
```java
public int trap(int[] height) {
    Stack<Integer> stack = new Stack<>();
    int water = 0;
    
    for (int i = 0; i < height.length; i++) {
        while (!stack.isEmpty() && height[i] > height[stack.peek()]) {
            int top = stack.pop();
            
            if (stack.isEmpty()) break;
            
            int distance = i - stack.peek() - 1;
            int boundedHeight = Math.min(height[i], height[stack.peek()]) - height[top];
            water += distance * boundedHeight;
        }
        
        stack.push(i);
    }
    
    return water;
}
```

### 19. Simplify Path
**Problem**: Simplify Unix-style file path.
```java
public String simplifyPath(String path) {
    Stack<String> stack = new Stack<>();
    String[] components = path.split("/");
    
    for (String component : components) {
        if (component.equals("..")) {
            if (!stack.isEmpty()) {
                stack.pop();
            }
        } else if (!component.equals(".") && !component.isEmpty()) {
            stack.push(component);
        }
    }
    
    StringBuilder result = new StringBuilder();
    for (String dir : stack) {
        result.append("/").append(dir);
    }
    
    return result.length() > 0 ? result.toString() : "/";
}
```

### 20. Exclusive Time of Functions
**Problem**: Calculate exclusive execution time of functions.
```java
public int[] exclusiveTime(int n, List<String> logs) {
    int[] result = new int[n];
    Stack<Integer> stack = new Stack<>();
    int prevTime = 0;
    
    for (String log : logs) {
        String[] parts = log.split(":");
        int id = Integer.parseInt(parts[0]);
        String type = parts[1];
        int time = Integer.parseInt(parts[2]);
        
        if (type.equals("start")) {
            if (!stack.isEmpty()) {
                result[stack.peek()] += time - prevTime;
            }
            stack.push(id);
            prevTime = time;
        } else {
            result[stack.pop()] += time - prevTime + 1;
            prevTime = time + 1;
        }
    }
    
    return result;
}
```

### 21. Score of Parentheses
**Problem**: Calculate score of balanced parentheses.
```java
public int scoreOfParentheses(String s) {
    Stack<Integer> stack = new Stack<>();
    stack.push(0);
    
    for (char c : s.toCharArray()) {
        if (c == '(') {
            stack.push(0);
        } else {
            int v = stack.pop();
            int w = stack.pop();
            stack.push(w + Math.max(2 * v, 1));
        }
    }
    
    return stack.pop();
}
```

### 22. Remove Duplicate Letters
**Problem**: Remove duplicate letters to get lexicographically smallest result.
```java
public String removeDuplicateLetters(String s) {
    int[] count = new int[26];
    boolean[] inStack = new boolean[26];
    Stack<Character> stack = new Stack<>();
    
    // Count frequency
    for (char c : s.toCharArray()) {
        count[c - 'a']++;
    }
    
    for (char c : s.toCharArray()) {
        count[c - 'a']--;
        
        if (inStack[c - 'a']) continue;
        
        while (!stack.isEmpty() && stack.peek() > c && count[stack.peek() - 'a'] > 0) {
            inStack[stack.pop() - 'a'] = false;
        }
        
        stack.push(c);
        inStack[c - 'a'] = true;
    }
    
    StringBuilder result = new StringBuilder();
    while (!stack.isEmpty()) {
        result.append(stack.pop());
    }
    
    return result.reverse().toString();
}
```

### 23. Next Greater Element II
**Problem**: Find next greater element in circular array.
```java
public int[] nextGreaterElements(int[] nums) {
    int n = nums.length;
    int[] result = new int[n];
    Arrays.fill(result, -1);
    Stack<Integer> stack = new Stack<>();
    
    for (int i = 0; i < 2 * n; i++) {
        while (!stack.isEmpty() && nums[stack.peek()] < nums[i % n]) {
            result[stack.pop()] = nums[i % n];
        }
        
        if (i < n) {
            stack.push(i);
        }
    }
    
    return result;
}
```

### 24. Validate Stack Sequences
**Problem**: Check if popped sequence is valid for given pushed sequence.
```java
public boolean validateStackSequences(int[] pushed, int[] popped) {
    Stack<Integer> stack = new Stack<>();
    int i = 0;
    
    for (int num : pushed) {
        stack.push(num);
        
        while (!stack.isEmpty() && stack.peek() == popped[i]) {
            stack.pop();
            i++;
        }
    }
    
    return i == popped.length;
}
```

### 25. Online Stock Span
**Problem**: Calculate stock price span.
```java
class StockSpanner {
    private Stack<int[]> stack;
    
    public StockSpanner() {
        stack = new Stack<>();
    }
    
    public int next(int price) {
        int span = 1;
        
        while (!stack.isEmpty() && stack.peek()[0] <= price) {
            span += stack.pop()[1];
        }
        
        stack.push(new int[]{price, span});
        return span;
    }
}
```

### 26. Car Fleet
**Problem**: Calculate number of car fleets.
```java
public int carFleet(int target, int[] position, int[] speed) {
    int n = position.length;
    double[][] cars = new double[n][2];
    
    for (int i = 0; i < n; i++) {
        cars[i][0] = position[i];
        cars[i][1] = (double)(target - position[i]) / speed[i];
    }
    
    Arrays.sort(cars, (a, b) -> Double.compare(a[0], b[0]));
    
    Stack<Double> stack = new Stack<>();
    
    for (int i = n - 1; i >= 0; i--) {
        double time = cars[i][1];
        
        if (stack.isEmpty() || time > stack.peek()) {
            stack.push(time);
        }
    }
    
    return stack.size();
}
```

### 27. Monotonic Array
**Problem**: Check if array is monotonic.
```java
public boolean isMonotonic(int[] nums) {
    boolean increasing = true;
    boolean decreasing = true;
    
    for (int i = 1; i < nums.length; i++) {
        if (nums[i] > nums[i - 1]) {
            decreasing = false;
        }
        if (nums[i] < nums[i - 1]) {
            increasing = false;
        }
    }
    
    return increasing || decreasing;
}
```

### 28. Design Circular Queue
**Problem**: Design circular queue.
```java
class MyCircularQueue {
    private int[] queue;
    private int head;
    private int tail;
    private int size;
    private int capacity;
    
    public MyCircularQueue(int k) {
        queue = new int[k];
        capacity = k;
        head = -1;
        tail = -1;
        size = 0;
    }
    
    public boolean enQueue(int value) {
        if (isFull()) return false;
        
        if (isEmpty()) {
            head = 0;
        }
        
        tail = (tail + 1) % capacity;
        queue[tail] = value;
        size++;
        
        return true;
    }
    
    public boolean deQueue() {
        if (isEmpty()) return false;
        
        if (size == 1) {
            head = -1;
            tail = -1;
        } else {
            head = (head + 1) % capacity;
        }
        
        size--;
        return true;
    }
    
    public int Front() {
        return isEmpty() ? -1 : queue[head];
    }
    
    public int Rear() {
        return isEmpty() ? -1 : queue[tail];
    }
    
    public boolean isEmpty() {
        return size == 0;
    }
    
    public boolean isFull() {
        return size == capacity;
    }
}
```

### 29. Design Circular Deque
**Problem**: Design circular double-ended queue.
```java
class MyCircularDeque {
    private int[] deque;
    private int front;
    private int rear;
    private int size;
    private int capacity;
    
    public MyCircularDeque(int k) {
        deque = new int[k];
        capacity = k;
        front = 0;
        rear = 0;
        size = 0;
    }
    
    public boolean insertFront(int value) {
        if (isFull()) return false;
        
        front = (front - 1 + capacity) % capacity;
        deque[front] = value;
        size++;
        
        return true;
    }
    
    public boolean insertLast(int value) {
        if (isFull()) return false;
        
        deque[rear] = value;
        rear = (rear + 1) % capacity;
        size++;
        
        return true;
    }
    
    public boolean deleteFront() {
        if (isEmpty()) return false;
        
        front = (front + 1) % capacity;
        size--;
        
        return true;
    }
    
    public boolean deleteLast() {
        if (isEmpty()) return false;
        
        rear = (rear - 1 + capacity) % capacity;
        size--;
        
        return true;
    }
    
    public int getFront() {
        return isEmpty() ? -1 : deque[front];
    }
    
    public int getRear() {
        return isEmpty() ? -1 : deque[(rear - 1 + capacity) % capacity];
    }
    
    public boolean isEmpty() {
        return size == 0;
    }
    
    public boolean isFull() {
        return size == capacity;
    }
}
```

### 30. Shortest Subarray with Sum at Least K
**Problem**: Find shortest subarray with sum ≥ K.
```java
public int shortestSubarray(int[] nums, int k) {
    int n = nums.length;
    long[] prefixSum = new long[n + 1];
    
    for (int i = 0; i < n; i++) {
        prefixSum[i + 1] = prefixSum[i] + nums[i];
    }
    
    Deque<Integer> deque = new ArrayDeque<>();
    int minLength = Integer.MAX_VALUE;
    
    for (int i = 0; i <= n; i++) {
        while (!deque.isEmpty() && prefixSum[i] - prefixSum[deque.peekFirst()] >= k) {
            minLength = Math.min(minLength, i - deque.pollFirst());
        }
        
        while (!deque.isEmpty() && prefixSum[i] <= prefixSum[deque.peekLast()]) {
            deque.pollLast();
        }
        
        deque.offerLast(i);
    }
    
    return minLength == Integer.MAX_VALUE ? -1 : minLength;
}
```