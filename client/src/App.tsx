import React, {useEffect, useState} from 'react';

function App() {
    const [state, setState] = useState(null);
    useEffect(() => {
      fetch("https://8w9y4dsbmh.execute-api.us-east-1.amazonaws.com/testFunction/hello-world", {
        method: "GET"
      })
          .then(response => response.json())
          .then(response => {
            setState(response)
          })
    }, []);

  return (
    <div className="App">
      <h1>{state}</h1>
    </div>
  );
}

export default App;
