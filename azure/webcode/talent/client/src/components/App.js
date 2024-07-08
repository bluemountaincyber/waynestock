import React from 'react';
import Header from './Header.js'
import LookupTalent from './LookupTalent.js'
import {Container} from 'semantic-ui-react'

export default function App() {
  return (
    <Container>
      <Header />
      <LookupTalent />
    </Container>
  );
}
