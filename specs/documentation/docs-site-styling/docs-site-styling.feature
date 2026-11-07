@domain:documentation @area:docs-site-styling @from:docs/stylesheets
Feature: Branded, self-contained documentation site
  Gives readers of the published chaos-toolbox docs a consistent, legible look that matches the project splash page without fetching anything from third-party servers.

  Background:
    Given the documentation site is published with the chaos-toolbox theme

  @id:documentation.docs-site-styling.001 @rule:docs.site-styling.shared-accent-palette @inferred @source:docs/stylesheets/extra.css#:root @questionable
  Scenario: The splash page and the docs share one accent palette
    Given the splash page is served at the site root and the rendered docs under /docs/
    When a reader opens the splash page and then the docs
    Then both pages use the same accent pair, sky blue #38bdf8 and blue #3b82f6
    And primary buttons and the home hero heading show a gradient from #38bdf8 to #3b82f6
    And links use #3b82f6 in the light scheme

  @id:documentation.docs-site-styling.002 @rule:docs.site-styling.no-external-font-requests @inferred @source:docs/stylesheets/extra.css#:root
  Scenario: The docs render in system fonts without fetching web fonts
    Given the reader's browser has no network access beyond the docs host
    When a reader opens any docs page
    Then body text renders in the operating system's sans-serif font
    And code renders in the operating system's monospace font
    And the page makes no request to a font host or CDN

  @id:documentation.docs-site-styling.003 @rule:docs.site-styling.legible-in-light-and-dark @inferred @source:docs/stylesheets/extra.css#[data-md-color-scheme="slate"]
  Scenario Outline: Links stay legible in both the light and the dark scheme
    Given the reader has chosen the <scheme> colour scheme
    When a reader views a docs page
    Then links are shown in <link_colour>
    And the page background is <background>

    Examples:
      | scheme | link_colour | background                               |
      | light  | #3b82f6     | the default white                        |
      | dark   | #38bdf8     | #0b0f1a, also behind the header and tabs |

  @id:documentation.docs-site-styling.004 @rule:docs.site-styling.no-placeholder-logo @inferred @source:docs/stylesheets/extra.css#.md-header__button.md-logo
  Scenario: The header shows no stand-in logo while the project has none
    Given the project has no logo configured
    When a reader views any docs page
    Then the header shows the site title with no logo icon
    And the navigation drawer title shows no logo icon
