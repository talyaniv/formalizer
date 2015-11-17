## Formalizer ##
Formalizer is an open-source gem for simplifying HTML-form filling and exporting:

 - Store blank contracts, agreements, disclosure sheets etc. as HTML templates.
 - Wrap blank data with &lt;formalizer&gt; tags:

    **before:** `name: ________`

    **after:** `name: <formalizer id="name">________</formalizer>`

 - Get user data from any source, or simply let Formalizer generate user-input forms for you.

 - Formalizer will replace the &lt;formalizer&gt; tags with user data:

    `name: <formalizer id="name">John D.</formalizer>`
 - Filled forms can be exported to PDF using [Wicked PDF][1] gem, or to raw html, for additional styling.
 


  [1]: https://github.com/mileszs/wicked_pdf