import './App.css';
import queryString from 'query-string';
import axios from 'axios';

export default function App() {
  const hashString = queryString.parse(window.location.hash);
  console.log(window.location.origin)

  async function storeToken(token) {
    localStorage.setItem('token', token);
    axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
    var query = await axios.get(window.location.origin + '/api/buy', { withCredentials: true }, (response) => {
      console.log(response);
    })
    return query;
  }

  return (
    <div className="App">
      { hashString.access_token ? storeToken(hashString.access_token) : null}
    </div>
  );
}
