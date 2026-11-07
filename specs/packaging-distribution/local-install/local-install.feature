@domain:packaging-distribution @area:local-install @from:chaos-toolbox/makefile
Feature: Installing chaosbox on a host
  Lets an operator or packager put the chaosbox tool and its man page onto a host, or a staging root, and take them off again without the container image.

  Background:
    Given the operator has a checkout of chaos-toolbox

  @id:packaging-distribution.local-install.001 @rule:packaging.local-install.installs-tool-and-man-page-under-prefix @inferred @source:Makefile#install
  Scenario Outline: Installing puts the tool and its man page under the chosen root and prefix
    Given the staging root is "<destdir>" and the prefix is "<prefix>"
    When the operator installs chaosbox
    Then "<destdir><prefix>/bin/chaosbox" exists and is executable by everyone
    And "<destdir><prefix>/share/man/man1/chaosbox.1" exists and is readable by everyone
    And the operator sees "installed chaosbox into <destdir><prefix>/bin"

    Examples:
      | destdir      | prefix     |
      |              | /usr/local |
      | /tmp/pkgroot | /usr       |
      | /tmp/pkgroot | /opt/chaos |

  @id:packaging-distribution.local-install.002 @rule:packaging.local-install.default-prefix-is-filesystem-root @inferred @source:Makefile#install @questionable
  Scenario: Without a prefix the tool installs straight under /bin
    Given no staging root and no prefix are chosen
    When the operator installs chaosbox
    Then the tool is placed at "/bin/chaosbox"
    And the man page is placed at "/share/man/man1/chaosbox.1"
    And the operator sees "installed chaosbox into /bin"

  @id:packaging-distribution.local-install.003 @rule:packaging.local-install.uninstall-removes-installed-files @inferred @source:Makefile#uninstall
  Scenario: Uninstalling removes exactly what installing put down
    Given chaosbox was installed with staging root "/tmp/pkgroot" and prefix "/usr/local"
    When the operator uninstalls chaosbox with the same staging root and prefix
    Then "/tmp/pkgroot/usr/local/bin/chaosbox" no longer exists
    And "/tmp/pkgroot/usr/local/share/man/man1/chaosbox.1" no longer exists
    And the bin and man1 directories are left in place
