# React Interview Questions and Concepts

Comprehensive React interview preparation materials with practical code examples, following the established patterns from Docker and SQL sections. This guide covers theoretical concepts and hands-on implementations for developers preparing for React technical interviews.

## Table of Contents
1. [React Fundamentals](#react-fundamentals)
2. [Components and JSX](#components-and-jsx)
3. [State and Props](#state-and-props)
4. [Hooks](#hooks)
5. [Event Handling](#event-handling)
6. [Lifecycle Methods](#lifecycle-methods)
7. [State Management](#state-management)
8. [Performance Optimization](#performance-optimization)
9. [Advanced Patterns](#advanced-patterns)
10. [Testing](#testing)
11. [Top 35 React Interview Questions](#top-35-react-interview-questions)

---

## React Fundamentals

React is a JavaScript library for building user interfaces, particularly web applications. It uses a component-based architecture and virtual DOM for efficient rendering.

### Key Concepts
- **Virtual DOM**: In-memory representation of real DOM elements
- **JSX**: JavaScript XML syntax extension
- **Components**: Reusable UI building blocks
- **Props**: Data passed to components
- **State**: Component's internal data

### Basic Setup
```bash
# Create React app
npx create-react-app my-app
cd my-app
npm start

# With Vite (faster alternative)
npm create vite@latest my-react-app -- --template react
cd my-react-app
npm install
npm run dev
```

---

## Components and JSX

### Functional Components
```jsx
// Basic functional component
function Welcome(props) {
  return <h1>Hello, {props.name}!</h1>;
}

// Arrow function component
const Welcome = (props) => {
  return <h1>Hello, {props.name}!</h1>;
};

// Component with destructuring
const Welcome = ({ name, age }) => {
  return (
    <div>
      <h1>Hello, {name}!</h1>
      <p>Age: {age}</p>
    </div>
  );
};
```#
## Class Components
```jsx
import React, { Component } from 'react';

class Welcome extends Component {
  constructor(props) {
    super(props);
    this.state = {
      count: 0
    };
  }

  render() {
    return (
      <div>
        <h1>Hello, {this.props.name}!</h1>
        <p>Count: {this.state.count}</p>
      </div>
    );
  }
}
```

### JSX Rules and Best Practices
```jsx
// JSX must return single parent element
const Component = () => {
  return (
    <div>
      <h1>Title</h1>
      <p>Content</p>
    </div>
  );
};

// Use React.Fragment or <> for multiple elements
const Component = () => {
  return (
    <>
      <h1>Title</h1>
      <p>Content</p>
    </>
  );
};

// Conditional rendering
const Component = ({ isLoggedIn }) => {
  return (
    <div>
      {isLoggedIn ? <h1>Welcome back!</h1> : <h1>Please log in</h1>}
      {isLoggedIn && <button>Logout</button>}
    </div>
  );
};

// List rendering
const TodoList = ({ todos }) => {
  return (
    <ul>
      {todos.map(todo => (
        <li key={todo.id}>{todo.text}</li>
      ))}
    </ul>
  );
};
```

---

## State and Props

### Props (Properties)
```jsx
// Parent component
const App = () => {
  const user = { name: 'John', age: 30 };
  
  return (
    <div>
      <UserProfile user={user} isAdmin={true} />
      <UserProfile name="Jane" age={25} isAdmin={false} />
    </div>
  );
};

// Child component
const UserProfile = ({ user, name, age, isAdmin }) => {
  const displayName = user ? user.name : name;
  const displayAge = user ? user.age : age;
  
  return (
    <div>
      <h2>{displayName}</h2>
      <p>Age: {displayAge}</p>
      {isAdmin && <span>Admin User</span>}
    </div>
  );
};

// Props validation with PropTypes
import PropTypes from 'prop-types';

UserProfile.propTypes = {
  name: PropTypes.string.isRequired,
  age: PropTypes.number,
  isAdmin: PropTypes.bool
};

UserProfile.defaultProps = {
  age: 0,
  isAdmin: false
};
```### Sta
te Management
```jsx
// useState Hook
import React, { useState } from 'react';

const Counter = () => {
  const [count, setCount] = useState(0);
  const [user, setUser] = useState({ name: '', email: '' });

  const increment = () => setCount(count + 1);
  const decrement = () => setCount(prev => prev - 1);
  
  const updateUser = (field, value) => {
    setUser(prev => ({
      ...prev,
      [field]: value
    }));
  };

  return (
    <div>
      <h2>Count: {count}</h2>
      <button onClick={increment}>+</button>
      <button onClick={decrement}>-</button>
      
      <input 
        value={user.name}
        onChange={(e) => updateUser('name', e.target.value)}
        placeholder="Name"
      />
      <input 
        value={user.email}
        onChange={(e) => updateUser('email', e.target.value)}
        placeholder="Email"
      />
    </div>
  );
};
```

---

## Hooks

### useState Hook
```jsx
import React, { useState } from 'react';

const FormExample = () => {
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    password: ''
  });

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log('Form submitted:', formData);
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        name="username"
        value={formData.username}
        onChange={handleChange}
        placeholder="Username"
      />
      <input
        name="email"
        type="email"
        value={formData.email}
        onChange={handleChange}
        placeholder="Email"
      />
      <input
        name="password"
        type="password"
        value={formData.password}
        onChange={handleChange}
        placeholder="Password"
      />
      <button type="submit">Submit</button>
    </form>
  );
};
```#
## useEffect Hook
```jsx
import React, { useState, useEffect } from 'react';

const DataFetcher = () => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Effect with dependency array
  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const response = await fetch('https://jsonplaceholder.typicode.com/posts');
        const result = await response.json();
        setData(result.slice(0, 5));
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []); // Empty dependency array - runs once on mount

  // Effect with cleanup
  useEffect(() => {
    const timer = setInterval(() => {
      console.log('Timer tick');
    }, 1000);

    return () => clearInterval(timer); // Cleanup function
  }, []);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;

  return (
    <ul>
      {data.map(item => (
        <li key={item.id}>{item.title}</li>
      ))}
    </ul>
  );
};
```

### useContext Hook
```jsx
import React, { createContext, useContext, useState } from 'react';

// Create context
const ThemeContext = createContext();

// Provider component
const ThemeProvider = ({ children }) => {
  const [theme, setTheme] = useState('light');

  const toggleTheme = () => {
    setTheme(prev => prev === 'light' ? 'dark' : 'light');
  };

  return (
    <ThemeContext.Provider value={{ theme, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  );
};

// Consumer component
const ThemedButton = () => {
  const { theme, toggleTheme } = useContext(ThemeContext);

  return (
    <button 
      onClick={toggleTheme}
      style={{
        backgroundColor: theme === 'light' ? '#fff' : '#333',
        color: theme === 'light' ? '#333' : '#fff'
      }}
    >
      Current theme: {theme}
    </button>
  );
};

// App component
const App = () => {
  return (
    <ThemeProvider>
      <div>
        <h1>Theme Example</h1>
        <ThemedButton />
      </div>
    </ThemeProvider>
  );
};
```##
# useReducer Hook
```jsx
import React, { useReducer } from 'react';

// Reducer function
const counterReducer = (state, action) => {
  switch (action.type) {
    case 'INCREMENT':
      return { count: state.count + 1 };
    case 'DECREMENT':
      return { count: state.count - 1 };
    case 'RESET':
      return { count: 0 };
    case 'SET_COUNT':
      return { count: action.payload };
    default:
      throw new Error(`Unknown action type: ${action.type}`);
  }
};

const CounterWithReducer = () => {
  const [state, dispatch] = useReducer(counterReducer, { count: 0 });

  return (
    <div>
      <h2>Count: {state.count}</h2>
      <button onClick={() => dispatch({ type: 'INCREMENT' })}>+</button>
      <button onClick={() => dispatch({ type: 'DECREMENT' })}>-</button>
      <button onClick={() => dispatch({ type: 'RESET' })}>Reset</button>
      <button onClick={() => dispatch({ type: 'SET_COUNT', payload: 10 })}>
        Set to 10
      </button>
    </div>
  );
};
```

### Custom Hooks
```jsx
import { useState, useEffect } from 'react';

// Custom hook for API calls
const useApi = (url) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const response = await fetch(url);
        const result = await response.json();
        setData(result);
      } catch (err) {
        setError(err);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [url]);

  return { data, loading, error };
};

// Custom hook for local storage
const useLocalStorage = (key, initialValue) => {
  const [storedValue, setStoredValue] = useState(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      return initialValue;
    }
  });

  const setValue = (value) => {
    try {
      setStoredValue(value);
      window.localStorage.setItem(key, JSON.stringify(value));
    } catch (error) {
      console.error(error);
    }
  };

  return [storedValue, setValue];
};

// Using custom hooks
const UserProfile = () => {
  const { data: user, loading, error } = useApi('/api/user');
  const [preferences, setPreferences] = useLocalStorage('userPrefs', {});

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error loading user</div>;

  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  );
};
```---


## Event Handling

### Basic Event Handling
```jsx
const EventExample = () => {
  const [inputValue, setInputValue] = useState('');

  const handleClick = (e) => {
    e.preventDefault();
    console.log('Button clicked!');
  };

  const handleChange = (e) => {
    setInputValue(e.target.value);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log('Form submitted with:', inputValue);
  };

  const handleKeyPress = (e) => {
    if (e.key === 'Enter') {
      console.log('Enter key pressed');
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="text"
        value={inputValue}
        onChange={handleChange}
        onKeyPress={handleKeyPress}
        placeholder="Type something..."
      />
      <button type="submit" onClick={handleClick}>
        Submit
      </button>
    </form>
  );
};
```

### Event Delegation and Performance
```jsx
const TodoList = ({ todos, onToggle, onDelete }) => {
  // Event delegation for better performance
  const handleListClick = (e) => {
    const todoId = e.target.dataset.todoId;
    const action = e.target.dataset.action;

    if (action === 'toggle') {
      onToggle(parseInt(todoId));
    } else if (action === 'delete') {
      onDelete(parseInt(todoId));
    }
  };

  return (
    <ul onClick={handleListClick}>
      {todos.map(todo => (
        <li key={todo.id}>
          <span 
            data-todo-id={todo.id}
            data-action="toggle"
            style={{ 
              textDecoration: todo.completed ? 'line-through' : 'none',
              cursor: 'pointer'
            }}
          >
            {todo.text}
          </span>
          <button 
            data-todo-id={todo.id}
            data-action="delete"
          >
            Delete
          </button>
        </li>
      ))}
    </ul>
  );
};
```

---

## Lifecycle Methods

### Class Component Lifecycle
```jsx
import React, { Component } from 'react';

class LifecycleExample extends Component {
  constructor(props) {
    super(props);
    this.state = {
      count: 0,
      data: null
    };
    console.log('Constructor called');
  }

  static getDerivedStateFromProps(nextProps, prevState) {
    console.log('getDerivedStateFromProps called');
    // Return new state or null
    return null;
  }

  componentDidMount() {
    console.log('componentDidMount called');
    // API calls, subscriptions, timers
    this.fetchData();
  }

  shouldComponentUpdate(nextProps, nextState) {
    console.log('shouldComponentUpdate called');
    // Return true/false to control re-rendering
    return nextState.count !== this.state.count;
  }

  getSnapshotBeforeUpdate(prevProps, prevState) {
    console.log('getSnapshotBeforeUpdate called');
    // Return snapshot value or null
    return null;
  }

  componentDidUpdate(prevProps, prevState, snapshot) {
    console.log('componentDidUpdate called');
    // Handle updates, API calls based on prop/state changes
  }

  componentWillUnmount() {
    console.log('componentWillUnmount called');
    // Cleanup: remove listeners, cancel requests, clear timers
  }

  fetchData = async () => {
    try {
      const response = await fetch('/api/data');
      const data = await response.json();
      this.setState({ data });
    } catch (error) {
      console.error('Error fetching data:', error);
    }
  };

  render() {
    console.log('Render called');
    return (
      <div>
        <h2>Count: {this.state.count}</h2>
        <button onClick={() => this.setState({ count: this.state.count + 1 })}>
          Increment
        </button>
      </div>
    );
  }
}
```### Func
tional Component Lifecycle with Hooks
```jsx
import React, { useState, useEffect, useLayoutEffect } from 'react';

const FunctionalLifecycle = () => {
  const [count, setCount] = useState(0);
  const [data, setData] = useState(null);

  // Equivalent to componentDidMount
  useEffect(() => {
    console.log('Component mounted');
    fetchData();
  }, []); // Empty dependency array

  // Equivalent to componentDidUpdate for specific state
  useEffect(() => {
    console.log('Count updated:', count);
  }, [count]); // Runs when count changes

  // Equivalent to componentWillUnmount
  useEffect(() => {
    const timer = setInterval(() => {
      console.log('Timer tick');
    }, 1000);

    return () => {
      console.log('Cleanup timer');
      clearInterval(timer);
    };
  }, []);

  // useLayoutEffect - runs synchronously after DOM mutations
  useLayoutEffect(() => {
    console.log('Layout effect - DOM updated');
  });

  const fetchData = async () => {
    try {
      const response = await fetch('/api/data');
      const result = await response.json();
      setData(result);
    } catch (error) {
      console.error('Error:', error);
    }
  };

  return (
    <div>
      <h2>Count: {count}</h2>
      <button onClick={() => setCount(count + 1)}>Increment</button>
      {data && <p>Data loaded: {data.message}</p>}
    </div>
  );
};
```

---

## State Management

### Context API for Global State
```jsx
import React, { createContext, useContext, useReducer } from 'react';

// Actions
const ACTIONS = {
  ADD_TODO: 'ADD_TODO',
  TOGGLE_TODO: 'TOGGLE_TODO',
  DELETE_TODO: 'DELETE_TODO',
  SET_FILTER: 'SET_FILTER'
};

// Reducer
const todoReducer = (state, action) => {
  switch (action.type) {
    case ACTIONS.ADD_TODO:
      return {
        ...state,
        todos: [...state.todos, {
          id: Date.now(),
          text: action.payload,
          completed: false
        }]
      };
    case ACTIONS.TOGGLE_TODO:
      return {
        ...state,
        todos: state.todos.map(todo =>
          todo.id === action.payload
            ? { ...todo, completed: !todo.completed }
            : todo
        )
      };
    case ACTIONS.DELETE_TODO:
      return {
        ...state,
        todos: state.todos.filter(todo => todo.id !== action.payload)
      };
    case ACTIONS.SET_FILTER:
      return {
        ...state,
        filter: action.payload
      };
    default:
      return state;
  }
};

// Context
const TodoContext = createContext();

// Provider
export const TodoProvider = ({ children }) => {
  const [state, dispatch] = useReducer(todoReducer, {
    todos: [],
    filter: 'all'
  });

  const addTodo = (text) => {
    dispatch({ type: ACTIONS.ADD_TODO, payload: text });
  };

  const toggleTodo = (id) => {
    dispatch({ type: ACTIONS.TOGGLE_TODO, payload: id });
  };

  const deleteTodo = (id) => {
    dispatch({ type: ACTIONS.DELETE_TODO, payload: id });
  };

  const setFilter = (filter) => {
    dispatch({ type: ACTIONS.SET_FILTER, payload: filter });
  };

  return (
    <TodoContext.Provider value={{
      todos: state.todos,
      filter: state.filter,
      addTodo,
      toggleTodo,
      deleteTodo,
      setFilter
    }}>
      {children}
    </TodoContext.Provider>
  );
};

// Custom hook to use context
export const useTodos = () => {
  const context = useContext(TodoContext);
  if (!context) {
    throw new Error('useTodos must be used within TodoProvider');
  }
  return context;
};
```---


## Performance Optimization

### React.memo
```jsx
import React, { memo, useState, useCallback, useMemo } from 'react';

// Memoized component - only re-renders if props change
const ExpensiveComponent = memo(({ data, onUpdate }) => {
  console.log('ExpensiveComponent rendered');
  
  const processedData = useMemo(() => {
    return data.map(item => ({
      ...item,
      processed: item.value * 2
    }));
  }, [data]);

  return (
    <div>
      {processedData.map(item => (
        <div key={item.id}>
          {item.name}: {item.processed}
          <button onClick={() => onUpdate(item.id)}>Update</button>
        </div>
      ))}
    </div>
  );
});

const ParentComponent = () => {
  const [count, setCount] = useState(0);
  const [data, setData] = useState([
    { id: 1, name: 'Item 1', value: 10 },
    { id: 2, name: 'Item 2', value: 20 }
  ]);

  // useCallback prevents function recreation on every render
  const handleUpdate = useCallback((id) => {
    setData(prev => prev.map(item => 
      item.id === id 
        ? { ...item, value: item.value + 1 }
        : item
    ));
  }, []);

  return (
    <div>
      <h2>Count: {count}</h2>
      <button onClick={() => setCount(count + 1)}>Increment Count</button>
      
      {/* ExpensiveComponent won't re-render when count changes */}
      <ExpensiveComponent data={data} onUpdate={handleUpdate} />
    </div>
  );
};
```

### useMemo and useCallback
```jsx
import React, { useState, useMemo, useCallback } from 'react';

const OptimizedComponent = () => {
  const [items, setItems] = useState([]);
  const [filter, setFilter] = useState('');
  const [sortOrder, setSortOrder] = useState('asc');

  // Expensive calculation memoized
  const filteredAndSortedItems = useMemo(() => {
    console.log('Filtering and sorting items');
    
    let filtered = items.filter(item => 
      item.name.toLowerCase().includes(filter.toLowerCase())
    );
    
    return filtered.sort((a, b) => {
      if (sortOrder === 'asc') {
        return a.name.localeCompare(b.name);
      }
      return b.name.localeCompare(a.name);
    });
  }, [items, filter, sortOrder]);

  // Memoized callback
  const addItem = useCallback((name) => {
    setItems(prev => [...prev, { 
      id: Date.now(), 
      name,
      createdAt: new Date()
    }]);
  }, []);

  const removeItem = useCallback((id) => {
    setItems(prev => prev.filter(item => item.id !== id));
  }, []);

  return (
    <div>
      <input
        value={filter}
        onChange={(e) => setFilter(e.target.value)}
        placeholder="Filter items..."
      />
      
      <select value={sortOrder} onChange={(e) => setSortOrder(e.target.value)}>
        <option value="asc">Ascending</option>
        <option value="desc">Descending</option>
      </select>

      <ItemList 
        items={filteredAndSortedItems}
        onRemove={removeItem}
      />
      
      <AddItemForm onAdd={addItem} />
    </div>
  );
};

const ItemList = memo(({ items, onRemove }) => {
  return (
    <ul>
      {items.map(item => (
        <li key={item.id}>
          {item.name}
          <button onClick={() => onRemove(item.id)}>Remove</button>
        </li>
      ))}
    </ul>
  );
});
```### 
Code Splitting and Lazy Loading
```jsx
import React, { Suspense, lazy } from 'react';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';

// Lazy load components
const Home = lazy(() => import('./components/Home'));
const About = lazy(() => import('./components/About'));
const Dashboard = lazy(() => import('./components/Dashboard'));

// Loading component
const LoadingSpinner = () => (
  <div style={{ textAlign: 'center', padding: '20px' }}>
    <div>Loading...</div>
  </div>
);

const App = () => {
  return (
    <Router>
      <nav>
        <Link to="/">Home</Link>
        <Link to="/about">About</Link>
        <Link to="/dashboard">Dashboard</Link>
      </nav>

      <Suspense fallback={<LoadingSpinner />}>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/about" element={<About />} />
          <Route path="/dashboard" element={<Dashboard />} />
        </Routes>
      </Suspense>
    </Router>
  );
};

// Dynamic import with error handling
const DynamicComponent = () => {
  const [Component, setComponent] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const loadComponent = async () => {
    try {
      setLoading(true);
      const module = await import('./HeavyComponent');
      setComponent(() => module.default);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <div>Loading component...</div>;
  if (error) return <div>Error: {error}</div>;
  if (!Component) {
    return <button onClick={loadComponent}>Load Heavy Component</button>;
  }

  return <Component />;
};
```

---

## Advanced Patterns

### Higher-Order Components (HOC)
```jsx
import React from 'react';

// HOC for authentication
const withAuth = (WrappedComponent) => {
  return function AuthenticatedComponent(props) {
    const [isAuthenticated, setIsAuthenticated] = useState(false);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
      // Check authentication status
      const checkAuth = async () => {
        try {
          const token = localStorage.getItem('token');
          if (token) {
            // Verify token with API
            const response = await fetch('/api/verify', {
              headers: { Authorization: `Bearer ${token}` }
            });
            setIsAuthenticated(response.ok);
          }
        } catch (error) {
          setIsAuthenticated(false);
        } finally {
          setLoading(false);
        }
      };

      checkAuth();
    }, []);

    if (loading) return <div>Checking authentication...</div>;
    
    if (!isAuthenticated) {
      return <div>Please log in to access this page.</div>;
    }

    return <WrappedComponent {...props} />;
  };
};

// Usage
const Dashboard = () => <div>Dashboard Content</div>;
const AuthenticatedDashboard = withAuth(Dashboard);
```#
## Render Props Pattern
```jsx
import React, { useState } from 'react';

// Render props component for mouse tracking
const MouseTracker = ({ render }) => {
  const [position, setPosition] = useState({ x: 0, y: 0 });

  const handleMouseMove = (e) => {
    setPosition({
      x: e.clientX,
      y: e.clientY
    });
  };

  return (
    <div 
      style={{ height: '100vh', width: '100%' }}
      onMouseMove={handleMouseMove}
    >
      {render(position)}
    </div>
  );
};

// Usage with render prop
const App = () => {
  return (
    <MouseTracker
      render={({ x, y }) => (
        <div>
          <h2>Mouse Position</h2>
          <p>X: {x}, Y: {y}</p>
          <div
            style={{
              position: 'absolute',
              left: x,
              top: y,
              width: 10,
              height: 10,
              backgroundColor: 'red',
              borderRadius: '50%'
            }}
          />
        </div>
      )}
    />
  );
};

// Alternative: children as function
const DataFetcher = ({ url, children }) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await fetch(url);
        const result = await response.json();
        setData(result);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [url]);

  return children({ data, loading, error });
};

// Usage
const UserProfile = () => {
  return (
    <DataFetcher url="/api/user">
      {({ data, loading, error }) => {
        if (loading) return <div>Loading...</div>;
        if (error) return <div>Error: {error}</div>;
        return <div>Welcome, {data.name}!</div>;
      }}
    </DataFetcher>
  );
};
```

### Error Boundaries
```jsx
import React from 'react';

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null, errorInfo: null };
  }

  static getDerivedStateFromError(error) {
    // Update state to show error UI
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    // Log error details
    console.error('Error caught by boundary:', error, errorInfo);
    this.setState({
      error: error,
      errorInfo: errorInfo
    });
  }

  render() {
    if (this.state.hasError) {
      return (
        <div style={{ padding: '20px', border: '1px solid red' }}>
          <h2>Something went wrong!</h2>
          <details style={{ whiteSpace: 'pre-wrap' }}>
            {this.state.error && this.state.error.toString()}
            <br />
            {this.state.errorInfo.componentStack}
          </details>
        </div>
      );
    }

    return this.props.children;
  }
}

// Functional Error Boundary (React 18+)
const ErrorBoundaryFunctional = ({ children, fallback }) => {
  return (
    <ErrorBoundary fallback={fallback}>
      {children}
    </ErrorBoundary>
  );
};

// Usage
const App = () => {
  return (
    <ErrorBoundary>
      <Header />
      <MainContent />
      <Footer />
    </ErrorBoundary>
  );
};
```---


## Testing

### Jest and React Testing Library
```jsx
import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import Counter from './Counter';

// Basic component testing
describe('Counter Component', () => {
  test('renders initial count', () => {
    render(<Counter initialCount={0} />);
    expect(screen.getByText('Count: 0')).toBeInTheDocument();
  });

  test('increments count when button is clicked', async () => {
    const user = userEvent.setup();
    render(<Counter initialCount={0} />);
    
    const incrementButton = screen.getByRole('button', { name: /increment/i });
    await user.click(incrementButton);
    
    expect(screen.getByText('Count: 1')).toBeInTheDocument();
  });

  test('calls onCountChange when count changes', async () => {
    const mockOnCountChange = jest.fn();
    const user = userEvent.setup();
    
    render(<Counter initialCount={0} onCountChange={mockOnCountChange} />);
    
    const incrementButton = screen.getByRole('button', { name: /increment/i });
    await user.click(incrementButton);
    
    expect(mockOnCountChange).toHaveBeenCalledWith(1);
  });
});

// Testing async operations
describe('UserProfile Component', () => {
  test('displays loading state initially', () => {
    render(<UserProfile userId="123" />);
    expect(screen.getByText('Loading...')).toBeInTheDocument();
  });

  test('displays user data after loading', async () => {
    // Mock API response
    global.fetch = jest.fn(() =>
      Promise.resolve({
        ok: true,
        json: () => Promise.resolve({
          id: '123',
          name: 'John Doe',
          email: 'john@example.com'
        })
      })
    );

    render(<UserProfile userId="123" />);
    
    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
    });

    expect(screen.getByText('john@example.com')).toBeInTheDocument();
  });

  test('displays error message on API failure', async () => {
    global.fetch = jest.fn(() =>
      Promise.reject(new Error('API Error'))
    );

    render(<UserProfile userId="123" />);
    
    await waitFor(() => {
      expect(screen.getByText(/error/i)).toBeInTheDocument();
    });
  });
});

// Testing custom hooks
import { renderHook, act } from '@testing-library/react';
import { useCounter } from './useCounter';

describe('useCounter hook', () => {
  test('should initialize with default value', () => {
    const { result } = renderHook(() => useCounter());
    expect(result.current.count).toBe(0);
  });

  test('should increment count', () => {
    const { result } = renderHook(() => useCounter());
    
    act(() => {
      result.current.increment();
    });
    
    expect(result.current.count).toBe(1);
  });

  test('should reset count', () => {
    const { result } = renderHook(() => useCounter(5));
    
    act(() => {
      result.current.increment();
      result.current.reset();
    });
    
    expect(result.current.count).toBe(5);
  });
});
```---


## Top 35 React Interview Questions

### Beginner Level (1-15)

#### 1. What is React and why is it used?
**Answer**: React is a JavaScript library for building user interfaces, particularly web applications. It's used for creating reusable UI components, managing application state, and efficiently updating the DOM through a virtual DOM.
**Code**:
```jsx
function Welcome() {
  return <h1>Hello, React!</h1>;
}
```

#### 2. What is JSX?
**Answer**: JSX (JavaScript XML) is a syntax extension that allows writing HTML-like code in JavaScript. It gets transpiled to React.createElement() calls.
**Code**:
```jsx
// JSX
const element = <h1>Hello, World!</h1>;

// Transpiled to:
const element = React.createElement('h1', null, 'Hello, World!');
```

#### 3. What's the difference between functional and class components?
**Answer**: Functional components are simpler, use hooks for state and lifecycle, while class components use this.state and lifecycle methods.
**Code**:
```jsx
// Functional Component
const FunctionalComponent = ({ name }) => {
  const [count, setCount] = useState(0);
  return <div>Hello {name}, Count: {count}</div>;
};

// Class Component
class ClassComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = { count: 0 };
  }
  
  render() {
    return <div>Hello {this.props.name}, Count: {this.state.count}</div>;
  }
}
```

#### 4. What are props in React?
**Answer**: Props (properties) are read-only data passed from parent to child components.
**Code**:
```jsx
const Parent = () => {
  return <Child name="John" age={25} />;
};

const Child = ({ name, age }) => {
  return <p>{name} is {age} years old</p>;
};
```

#### 5. What is state in React?
**Answer**: State is mutable data that belongs to a component and can trigger re-renders when changed.
**Code**:
```jsx
const Counter = () => {
  const [count, setCount] = useState(0);
  
  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>Increment</button>
    </div>
  );
};
```

#### 6. What is the useState hook?
**Answer**: useState is a hook that allows functional components to have state variables.
**Code**:
```jsx
const [state, setState] = useState(initialValue);

// Example
const [name, setName] = useState('');
const [user, setUser] = useState({ name: '', email: '' });
```

#### 7. What is the useEffect hook?
**Answer**: useEffect handles side effects in functional components, replacing lifecycle methods.
**Code**:
```jsx
useEffect(() => {
  // Effect logic
  return () => {
    // Cleanup logic
  };
}, [dependencies]);

// Example
useEffect(() => {
  document.title = `Count: ${count}`;
}, [count]);
```#### 
8. How do you handle events in React?
**Answer**: Events are handled using event handlers passed as props, with SyntheticEvent objects.
**Code**:
```jsx
const Button = () => {
  const handleClick = (e) => {
    e.preventDefault();
    console.log('Button clicked!');
  };

  return <button onClick={handleClick}>Click me</button>;
};
```

#### 9. What is conditional rendering?
**Answer**: Rendering different content based on conditions using JavaScript operators.
**Code**:
```jsx
const Greeting = ({ isLoggedIn, user }) => {
  return (
    <div>
      {isLoggedIn ? (
        <h1>Welcome back, {user.name}!</h1>
      ) : (
        <h1>Please sign in</h1>
      )}
      {isLoggedIn && <button>Logout</button>}
    </div>
  );
};
```

#### 10. How do you render lists in React?
**Answer**: Use the map() method to render arrays of data, with unique keys for each item.
**Code**:
```jsx
const TodoList = ({ todos }) => {
  return (
    <ul>
      {todos.map(todo => (
        <li key={todo.id}>
          {todo.text} - {todo.completed ? 'Done' : 'Pending'}
        </li>
      ))}
    </ul>
  );
};
```

#### 11. What are keys in React and why are they important?
**Answer**: Keys help React identify which items have changed, are added, or removed for efficient re-rendering.
**Code**:
```jsx
// Good - unique keys
{users.map(user => (
  <User key={user.id} user={user} />
))}

// Bad - array index as key (avoid when list can change)
{users.map((user, index) => (
  <User key={index} user={user} />
))}
```

#### 12. What is the virtual DOM?
**Answer**: Virtual DOM is a JavaScript representation of the real DOM that React uses to optimize updates by comparing (diffing) and updating only changed elements.
**Code**:
```jsx
// React creates virtual DOM elements
const element = React.createElement('div', { className: 'container' }, 'Hello');

// Which represents this real DOM
// <div class="container">Hello</div>
```

#### 13. What are React fragments?
**Answer**: Fragments let you group multiple elements without adding extra DOM nodes.
**Code**:
```jsx
// Using React.Fragment
const Component = () => {
  return (
    <React.Fragment>
      <h1>Title</h1>
      <p>Description</p>
    </React.Fragment>
  );
};

// Using short syntax
const Component = () => {
  return (
    <>
      <h1>Title</h1>
      <p>Description</p>
    </>
  );
};
```

#### 14. How do you pass data from child to parent component?
**Answer**: Pass a callback function from parent to child, child calls it with data.
**Code**:
```jsx
const Parent = () => {
  const [message, setMessage] = useState('');
  
  const handleMessage = (msg) => {
    setMessage(msg);
  };
  
  return (
    <div>
      <p>Message from child: {message}</p>
      <Child onMessage={handleMessage} />
    </div>
  );
};

const Child = ({ onMessage }) => {
  return (
    <button onClick={() => onMessage('Hello from child!')}>
      Send Message
    </button>
  );
};
```

#### 15. What is prop drilling and how can you avoid it?
**Answer**: Prop drilling is passing props through multiple component levels. Avoid with Context API or state management libraries.
**Code**:
```jsx
// Prop drilling problem
const App = () => {
  const user = { name: 'John' };
  return <Level1 user={user} />;
};

const Level1 = ({ user }) => <Level2 user={user} />;
const Level2 = ({ user }) => <Level3 user={user} />;
const Level3 = ({ user }) => <div>{user.name}</div>;

// Solution with Context
const UserContext = createContext();

const App = () => {
  const user = { name: 'John' };
  return (
    <UserContext.Provider value={user}>
      <Level1 />
    </UserContext.Provider>
  );
};

const Level3 = () => {
  const user = useContext(UserContext);
  return <div>{user.name}</div>;
};
```###
 Intermediate Level (16-25)

#### 16. What is the useContext hook?
**Answer**: useContext allows consuming context values without wrapping components in Context.Consumer.
**Code**:
```jsx
const ThemeContext = createContext();

const App = () => {
  return (
    <ThemeContext.Provider value="dark">
      <ThemedComponent />
    </ThemeContext.Provider>
  );
};

const ThemedComponent = () => {
  const theme = useContext(ThemeContext);
  return <div className={`theme-${theme}`}>Themed content</div>;
};
```

#### 17. What is useReducer and when would you use it?
**Answer**: useReducer manages complex state logic with actions, similar to Redux. Use for complex state updates or when state depends on previous state.
**Code**:
```jsx
const initialState = { count: 0 };

const reducer = (state, action) => {
  switch (action.type) {
    case 'increment':
      return { count: state.count + 1 };
    case 'decrement':
      return { count: state.count - 1 };
    case 'reset':
      return initialState;
    default:
      throw new Error();
  }
};

const Counter = () => {
  const [state, dispatch] = useReducer(reducer, initialState);
  
  return (
    <div>
      Count: {state.count}
      <button onClick={() => dispatch({ type: 'increment' })}>+</button>
      <button onClick={() => dispatch({ type: 'decrement' })}>-</button>
      <button onClick={() => dispatch({ type: 'reset' })}>Reset</button>
    </div>
  );
};
```

#### 18. What are custom hooks?
**Answer**: Custom hooks are JavaScript functions that use React hooks and allow sharing stateful logic between components.
**Code**:
```jsx
// Custom hook for API calls
const useApi = (url) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await fetch(url);
        const result = await response.json();
        setData(result);
      } catch (err) {
        setError(err);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [url]);

  return { data, loading, error };
};

// Usage
const UserProfile = ({ userId }) => {
  const { data: user, loading, error } = useApi(`/api/users/${userId}`);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;
  return <div>Hello, {user.name}!</div>;
};
```

#### 19. What is React.memo and when should you use it?
**Answer**: React.memo is a higher-order component that memoizes the result and only re-renders if props change.
**Code**:
```jsx
const ExpensiveComponent = React.memo(({ data, onUpdate }) => {
  console.log('ExpensiveComponent rendered');
  
  return (
    <div>
      {data.map(item => (
        <div key={item.id}>
          {item.name}
          <button onClick={() => onUpdate(item.id)}>Update</button>
        </div>
      ))}
    </div>
  );
});

// With custom comparison
const MyComponent = React.memo(({ user, posts }) => {
  return <div>{user.name} has {posts.length} posts</div>;
}, (prevProps, nextProps) => {
  return prevProps.user.id === nextProps.user.id &&
         prevProps.posts.length === nextProps.posts.length;
});
```

#### 20. What are useCallback and useMemo?
**Answer**: useCallback memoizes functions, useMemo memoizes computed values. Both prevent unnecessary re-computations.
**Code**:
```jsx
const ParentComponent = ({ items }) => {
  const [filter, setFilter] = useState('');

  // useMemo - memoize expensive calculation
  const filteredItems = useMemo(() => {
    return items.filter(item => 
      item.name.toLowerCase().includes(filter.toLowerCase())
    );
  }, [items, filter]);

  // useCallback - memoize function
  const handleItemClick = useCallback((id) => {
    console.log('Item clicked:', id);
  }, []);

  return (
    <div>
      <input 
        value={filter}
        onChange={(e) => setFilter(e.target.value)}
      />
      <ItemList items={filteredItems} onItemClick={handleItemClick} />
    </div>
  );
};
```#### 2
1. What are Higher-Order Components (HOCs)?
**Answer**: HOCs are functions that take a component and return a new component with additional props or behavior.
**Code**:
```jsx
// HOC for loading state
const withLoading = (WrappedComponent) => {
  return function WithLoadingComponent({ isLoading, ...props }) {
    if (isLoading) {
      return <div>Loading...</div>;
    }
    return <WrappedComponent {...props} />;
  };
};

// Usage
const UserList = ({ users }) => (
  <ul>
    {users.map(user => <li key={user.id}>{user.name}</li>)}
  </ul>
);

const UserListWithLoading = withLoading(UserList);

// In parent component
<UserListWithLoading users={users} isLoading={loading} />
```

#### 22. What is the render props pattern?
**Answer**: Render props is a technique for sharing code between components using a prop whose value is a function.
**Code**:
```jsx
const DataProvider = ({ render, url }) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch(url)
      .then(response => response.json())
      .then(data => {
        setData(data);
        setLoading(false);
      });
  }, [url]);

  return render({ data, loading });
};

// Usage
const App = () => (
  <DataProvider
    url="/api/users"
    render={({ data, loading }) => (
      loading ? <div>Loading...</div> : <UserList users={data} />
    )}
  />
);
```

#### 23. What are Error Boundaries?
**Answer**: Error Boundaries are components that catch JavaScript errors in their component tree and display fallback UI.
**Code**:
```jsx
class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    console.error('Error caught:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return <h1>Something went wrong.</h1>;
    }

    return this.props.children;
  }
}

// Usage
<ErrorBoundary>
  <MyComponent />
</ErrorBoundary>
```

#### 24. What is code splitting in React?
**Answer**: Code splitting breaks your bundle into smaller chunks that can be loaded on demand, improving performance.
**Code**:
```jsx
import React, { Suspense, lazy } from 'react';

// Lazy load components
const LazyComponent = lazy(() => import('./LazyComponent'));
const AnotherLazyComponent = lazy(() => 
  import('./AnotherComponent').then(module => ({
    default: module.AnotherComponent
  }))
);

const App = () => (
  <div>
    <Suspense fallback={<div>Loading...</div>}>
      <LazyComponent />
      <AnotherLazyComponent />
    </Suspense>
  </div>
);
```

#### 25. How do you optimize React performance?
**Answer**: Use React.memo, useMemo, useCallback, code splitting, lazy loading, and avoid inline objects/functions.
**Code**:
```jsx
const OptimizedComponent = React.memo(({ items, onItemClick }) => {
  // Memoize expensive calculations
  const expensiveValue = useMemo(() => {
    return items.reduce((sum, item) => sum + item.value, 0);
  }, [items]);

  // Memoize callbacks
  const handleClick = useCallback((id) => {
    onItemClick(id);
  }, [onItemClick]);

  return (
    <div>
      <p>Total: {expensiveValue}</p>
      {items.map(item => (
        <Item 
          key={item.id} 
          item={item} 
          onClick={handleClick}
        />
      ))}
    </div>
  );
});

// Avoid inline objects and functions
const Parent = () => {
  const [items, setItems] = useState([]);
  
  // Good - memoized callback
  const handleItemClick = useCallback((id) => {
    console.log('Clicked:', id);
  }, []);

  return (
    <OptimizedComponent 
      items={items}
      onItemClick={handleItemClick}
    />
  );
};
```##
# Advanced Level (26-35)

#### 26. What is React Fiber?
**Answer**: React Fiber is the new reconciliation algorithm that enables incremental rendering, allowing React to pause and resume work.
**Code**:
```jsx
// Fiber enables features like:
// 1. Time slicing
// 2. Suspense
// 3. Concurrent features

const App = () => {
  return (
    <Suspense fallback={<Loading />}>
      <ExpensiveComponent />
    </Suspense>
  );
};

// Concurrent features (React 18+)
import { startTransition } from 'react';

const SearchComponent = () => {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);

  const handleSearch = (value) => {
    setQuery(value); // Urgent update
    
    startTransition(() => {
      // Non-urgent update
      setResults(searchResults(value));
    });
  };

  return (
    <div>
      <input onChange={(e) => handleSearch(e.target.value)} />
      <SearchResults results={results} />
    </div>
  );
};
```

#### 27. What are Portals in React?
**Answer**: Portals provide a way to render children into a DOM node outside the parent component's DOM hierarchy.
**Code**:
```jsx
import ReactDOM from 'react-dom';

const Modal = ({ children, isOpen }) => {
  if (!isOpen) return null;

  return ReactDOM.createPortal(
    <div className="modal-overlay">
      <div className="modal">
        {children}
      </div>
    </div>,
    document.getElementById('modal-root')
  );
};

// Usage
const App = () => {
  const [showModal, setShowModal] = useState(false);

  return (
    <div>
      <button onClick={() => setShowModal(true)}>Open Modal</button>
      <Modal isOpen={showModal}>
        <h2>Modal Content</h2>
        <button onClick={() => setShowModal(false)}>Close</button>
      </Modal>
    </div>
  );
};
```

#### 28. What is React.StrictMode?
**Answer**: StrictMode is a development tool that highlights potential problems by running additional checks and warnings.
**Code**:
```jsx
import React from 'react';

const App = () => {
  return (
    <React.StrictMode>
      <div>
        <Header />
        <MainContent />
        <Footer />
      </div>
    </React.StrictMode>
  );
};

// StrictMode helps identify:
// - Components with unsafe lifecycles
// - Legacy string ref API usage
// - Deprecated findDOMNode usage
// - Unexpected side effects
// - Legacy context API
```

#### 29. How do you implement server-side rendering (SSR) with React?
**Answer**: SSR renders React components on the server and sends HTML to the client. Use frameworks like Next.js or implement with ReactDOMServer.
**Code**:
```jsx
// Server-side (Node.js)
import ReactDOMServer from 'react-dom/server';
import App from './App';

const html = ReactDOMServer.renderToString(<App />);

const fullHtml = `
<!DOCTYPE html>
<html>
  <head><title>SSR App</title></head>
  <body>
    <div id="root">${html}</div>
    <script src="/bundle.js"></script>
  </body>
</html>
`;

// Client-side hydration
import ReactDOM from 'react-dom';
import App from './App';

ReactDOM.hydrate(<App />, document.getElementById('root'));

// With Next.js
export async function getServerSideProps(context) {
  const data = await fetchData();
  return {
    props: { data }
  };
}

const Page = ({ data }) => {
  return <div>{data.title}</div>;
};
```

#### 30. What are React 18's new features?
**Answer**: React 18 introduced concurrent features, automatic batching, Suspense improvements, and new hooks.
**Code**:
```jsx
// Automatic batching
const handleClick = () => {
  setCount(c => c + 1);
  setFlag(f => !f);
  // Both updates are batched automatically
};

// Concurrent features
import { startTransition, useDeferredValue } from 'react';

const SearchApp = () => {
  const [query, setQuery] = useState('');
  const deferredQuery = useDeferredValue(query);

  const handleChange = (value) => {
    setQuery(value);
    
    startTransition(() => {
      // This update has lower priority
      performExpensiveOperation(value);
    });
  };

  return (
    <div>
      <input onChange={(e) => handleChange(e.target.value)} />
      <SearchResults query={deferredQuery} />
    </div>
  );
};

// New Suspense features
const App = () => {
  return (
    <Suspense fallback={<Loading />}>
      <ProfilePage />
      <Suspense fallback={<PostsLoading />}>
        <ProfilePosts />
      </Suspense>
    </Suspense>
  );
};
```#
### 31. How do you handle forms in React?
**Answer**: Handle forms using controlled components with state, or uncontrolled components with refs.
**Code**:
```jsx
// Controlled components
const ControlledForm = () => {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    message: ''
  });

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log('Form data:', formData);
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        name="name"
        value={formData.name}
        onChange={handleChange}
        placeholder="Name"
      />
      <input
        name="email"
        type="email"
        value={formData.email}
        onChange={handleChange}
        placeholder="Email"
      />
      <textarea
        name="message"
        value={formData.message}
        onChange={handleChange}
        placeholder="Message"
      />
      <button type="submit">Submit</button>
    </form>
  );
};

// Uncontrolled components with refs
const UncontrolledForm = () => {
  const nameRef = useRef();
  const emailRef = useRef();

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log({
      name: nameRef.current.value,
      email: emailRef.current.value
    });
  };

  return (
    <form onSubmit={handleSubmit}>
      <input ref={nameRef} placeholder="Name" />
      <input ref={emailRef} type="email" placeholder="Email" />
      <button type="submit">Submit</button>
    </form>
  );
};
```

#### 32. What is the difference between controlled and uncontrolled components?
**Answer**: Controlled components have their state managed by React, uncontrolled components manage their own state internally.
**Code**:
```jsx
// Controlled component
const ControlledInput = () => {
  const [value, setValue] = useState('');

  return (
    <input
      value={value}
      onChange={(e) => setValue(e.target.value)}
    />
  );
};

// Uncontrolled component
const UncontrolledInput = () => {
  const inputRef = useRef();

  const getValue = () => {
    console.log(inputRef.current.value);
  };

  return (
    <div>
      <input ref={inputRef} defaultValue="Initial value" />
      <button onClick={getValue}>Get Value</button>
    </div>
  );
};
```

#### 33. How do you implement routing in React?
**Answer**: Use React Router for client-side routing with components like BrowserRouter, Routes, Route, and Link.
**Code**:
```jsx
import { BrowserRouter as Router, Routes, Route, Link, useParams, useNavigate } from 'react-router-dom';

const App = () => {
  return (
    <Router>
      <nav>
        <Link to="/">Home</Link>
        <Link to="/about">About</Link>
        <Link to="/users">Users</Link>
      </nav>

      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/about" element={<About />} />
        <Route path="/users" element={<Users />} />
        <Route path="/users/:id" element={<UserDetail />} />
        <Route path="*" element={<NotFound />} />
      </Routes>
    </Router>
  );
};

const UserDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();

  return (
    <div>
      <h2>User {id}</h2>
      <button onClick={() => navigate('/users')}>Back to Users</button>
    </div>
  );
};

// Protected routes
const ProtectedRoute = ({ children }) => {
  const isAuthenticated = useAuth();
  
  return isAuthenticated ? children : <Navigate to="/login" />;
};

<Route 
  path="/dashboard" 
  element={
    <ProtectedRoute>
      <Dashboard />
    </ProtectedRoute>
  } 
/>
```

#### 34. How do you test React components?
**Answer**: Use Jest and React Testing Library for unit testing, focusing on user interactions and behavior.
**Code**:
```jsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import Counter from './Counter';

describe('Counter Component', () => {
  test('renders initial count', () => {
    render(<Counter initialCount={5} />);
    expect(screen.getByText('Count: 5')).toBeInTheDocument();
  });

  test('increments count on button click', async () => {
    const user = userEvent.setup();
    render(<Counter initialCount={0} />);
    
    const button = screen.getByRole('button', { name: /increment/i });
    await user.click(button);
    
    expect(screen.getByText('Count: 1')).toBeInTheDocument();
  });

  test('calls onCountChange prop', async () => {
    const mockOnCountChange = jest.fn();
    const user = userEvent.setup();
    
    render(<Counter initialCount={0} onCountChange={mockOnCountChange} />);
    
    const button = screen.getByRole('button', { name: /increment/i });
    await user.click(button);
    
    expect(mockOnCountChange).toHaveBeenCalledWith(1);
  });
});

// Testing async operations
test('displays user data after loading', async () => {
  global.fetch = jest.fn(() =>
    Promise.resolve({
      ok: true,
      json: () => Promise.resolve({ name: 'John Doe' })
    })
  );

  render(<UserProfile userId="123" />);
  
  await waitFor(() => {
    expect(screen.getByText('John Doe')).toBeInTheDocument();
  });
});
```

#### 35. What are some React best practices?
**Answer**: Use functional components, proper key props, avoid inline functions, implement error boundaries, and follow naming conventions.
**Code**:
```jsx
// Good practices
const UserList = ({ users, onUserClick }) => {
  // Memoize expensive calculations
  const sortedUsers = useMemo(() => 
    users.sort((a, b) => a.name.localeCompare(b.name)), 
    [users]
  );

  // Memoize callbacks
  const handleUserClick = useCallback((userId) => {
    onUserClick(userId);
  }, [onUserClick]);

  return (
    <div>
      {sortedUsers.map(user => (
        <UserCard
          key={user.id} // Unique, stable keys
          user={user}
          onClick={handleUserClick}
        />
      ))}
    </div>
  );
};

// Component composition over inheritance
const Button = ({ variant = 'primary', size = 'medium', children, ...props }) => {
  const className = `btn btn-${variant} btn-${size}`;
  
  return (
    <button className={className} {...props}>
      {children}
    </button>
  );
};

// Custom hooks for reusable logic
const useLocalStorage = (key, initialValue) => {
  const [storedValue, setStoredValue] = useState(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      return initialValue;
    }
  });

  const setValue = (value) => {
    try {
      setStoredValue(value);
      window.localStorage.setItem(key, JSON.stringify(value));
    } catch (error) {
      console.error(error);
    }
  };

  return [storedValue, setValue];
};
```---


## How to Use This Repository

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/react-interview-prep.git
   cd react-interview-prep
   ```

2. **Explore Topics**:
   - Each section covers specific React concepts with practical examples
   - Code examples are provided for hands-on practice
   - Questions are categorized by difficulty level

3. **Practice with Code**:
   - Copy code examples into your React environment
   - Modify examples to understand concepts better
   - Create your own variations of the examples

4. **Study Interview Questions**:
   - Review questions by difficulty level
   - Practice explaining concepts in your own words
   - Implement the code examples from scratch

5. **Build Projects**:
   - Apply learned concepts in real projects
   - Combine multiple concepts in single applications
   - Practice with different React patterns and architectures

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a new branch (`git checkout -b add-new-content`)
3. Add new questions, examples, or improvements
4. Commit changes (`git commit -m "Add new React concept"`)
5. Push to your fork (`git push origin add-new-content`)
6. Open a pull request with clear description

Please ensure:
- Code examples are tested and working
- Explanations are clear and accurate
- Follow the existing format and structure
- Include both theoretical explanations and practical code

## Resources

### Official Documentation
- [React Documentation](https://react.dev/)
- [React Hooks](https://react.dev/reference/react)
- [React Router](https://reactrouter.com/)

### Learning Platforms
- [React Tutorial](https://react.dev/learn)
- [freeCodeCamp React Course](https://www.freecodecamp.org/learn/front-end-development-libraries/)
- [React Patterns](https://reactpatterns.com/)

### Testing Resources
- [React Testing Library](https://testing-library.com/docs/react-testing-library/intro/)
- [Jest Documentation](https://jestjs.io/docs/getting-started)

### Advanced Topics
- [React Fiber Architecture](https://github.com/acdlite/react-fiber-architecture)
- [React Performance](https://react.dev/learn/render-and-commit)
- [React 18 Features](https://react.dev/blog/2022/03/29/react-v18)

## License

This repository is licensed under the [MIT License](LICENSE). Use, modify, and share for educational and professional purposes.

---

*Happy coding and good luck with your React interviews! 🚀*