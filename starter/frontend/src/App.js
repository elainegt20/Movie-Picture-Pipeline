import React, { useState } from 'react';
import MovieList from './components/MovieList';
import MovieDetails from './components/MovieDetails';
import './App.css';

// adding this comemnt to test the deployment workflow
// i am testing the deployment workflow again
// i am testing the deployment workflow again 4

export default function App() {
  const [selectedMovie, setSelectedMovie] = useState(null);

  const handleMovieClick = (movie) => {
    setSelectedMovie(movie);
  };

  return (
    <div className="container">
      <h1>Movie List</h1>

      <MovieList onMovieClick={handleMovieClick} />

      {selectedMovie && (
        <>
          <h1>Movie Details</h1>
          <MovieDetails movie={selectedMovie} />
        </>
      )}
    </div>
  );
}
