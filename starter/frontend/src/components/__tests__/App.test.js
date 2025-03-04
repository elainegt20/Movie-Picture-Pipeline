import { render, screen } from '@testing-library/react';
import React from 'react';

import App from '../../App';

const movieHeading = 'WRONG_HEADING';

test('renders Movie List heading', () => {
  render(<App />);
  const linkElement = screen.getByText(movieHeading);
  expect(linkElement).toBeInTheDocument();
});
