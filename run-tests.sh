
#!/bin/bash

# Nettoyage des anciens rapports
rm -rf test-results/
rm -rf G-rez-l-int-gration-et-la-livraison-continue-Application-Angular/coverage/
rm -rf G-rez-l-int-gration-et-la-livraison-continue-Application-Angular/reports/
# Script pour lancer les tests backend (Java) et frontend (Angular)
# et générer des rapports JUnit XML pour GitHub Actions

set -e

# Backend Java
cd G-rez-l-int-gration-et-la-livraison-continue-Application-Java

echo "[Backend] Lancement des tests Java..."
./gradlew clean test --no-daemon --console=plain || echo "[Backend] Les tests Java ont échoué, on continue."
# Les rapports JUnit sont générés dans build/test-results/test
cd ..

# Frontend Angular
cd G-rez-l-int-gration-et-la-livraison-continue-Application-Angular

echo "[Frontend] Lancement des tests Angular..."
npm install
npm run test -- --watch=false --browsers=ChromeHeadless --reporters=junit,progress --code-coverage
# Les rapports JUnit sont générés dans ./test-results/junit/
cd ..

# Création du dossier test-results/ à la racine si besoin
mkdir -p test-results

# Copie des rapports Java
if [ -d "G-rez-l-int-gration-et-la-livraison-continue-Application-Java/build/test-results/test" ]; then
	cp G-rez-l-int-gration-et-la-livraison-continue-Application-Java/build/test-results/test/*.xml test-results/ 2>/dev/null || true
fi

# Copie des rapports Angular (test-results/junit ou reports)
if [ -d "G-rez-l-int-gration-et-la-livraison-continue-Application-Angular/test-results/junit" ]; then
	cp G-rez-l-int-gration-et-la-livraison-continue-Application-Angular/test-results/junit/*.xml test-results/ 2>/dev/null || true
fi
if [ -d "G-rez-l-int-gration-et-la-livraison-continue-Application-Angular/reports" ]; then
	cp G-rez-l-int-gration-et-la-livraison-continue-Application-Angular/reports/*.xml test-results/ 2>/dev/null || true
fi


echo "\nRésumé de la couverture de code (Angular) :"
if [ -f "G-rez-l-int-gration-et-la-livraison-continue-Application-Angular/coverage/olympic-games-starter/index.html" ]; then
	grep -A2 'Statements' G-rez-l-int-gration-et-la-livraison-continue-Application-Angular/coverage/olympic-games-starter/index.html | head -n 3 | sed -E 's/<[^>]+>//g' | paste -sd ' ' - | sed 's/  */ /g' | awk '{print "Statements   : "$2" ( "$3" )"}'
	grep -A2 'Branches' G-rez-l-int-gration-et-la-livraison-continue-Application-Angular/coverage/olympic-games-starter/index.html | head -n 3 | sed -E 's/<[^>]+>//g' | paste -sd ' ' - | sed 's/  */ /g' | awk '{print "Branches     : "$2" ( "$3" )"}'
	grep -A2 'Functions' G-rez-l-int-gration-et-la-livraison-continue-Application-Angular/coverage/olympic-games-starter/index.html | head -n 3 | sed -E 's/<[^>]+>//g' | paste -sd ' ' - | sed 's/  */ /g' | awk '{print "Functions    : "$2" ( "$3" )"}'
	grep -A2 'Lines' G-rez-l-int-gration-et-la-livraison-continue-Application-Angular/coverage/olympic-games-starter/index.html | head -n 3 | sed -E 's/<[^>]+>//g' | paste -sd ' ' - | sed 's/  */ /g' | awk '{print "Lines        : "$2" ( "$3" )"}'
else
	echo "Pas de rapport de couverture trouvé."
fi
ANGULAR_XML="test-results/TESTS-Chrome_Headless_145.0.0.0_(Windows_10).xml"
COVERAGE_HTML="G-rez-l-int-gration-et-la-livraison-continue-Application-Angular/coverage/olympic-games-starter/index.html"
if [ -f "$ANGULAR_XML" ] && [ -f "$COVERAGE_HTML" ]; then
  get_coverage_line() {
    local label="$1"
    local percent=$(grep -A2 ">$label<" "$COVERAGE_HTML" | grep 'strong' | head -n1 | sed -E 's/.*>([0-9.]+%)<.*/\1/')
    local frac=$(grep -A2 ">$label<" "$COVERAGE_HTML" | grep 'fraction' | head -n1 | sed -E 's/.*>([0-9]+\/[0-9]+)<.*/\1/')
    printf "%s   : %s (%s)\n" "$label" "$percent" "$frac"
  }
  COVERAGE_SUMMARY="$(
    echo "=============================== Coverage summary ==============================="
    get_coverage_line "Statements"
    get_coverage_line "Branches"
    get_coverage_line "Functions"
    get_coverage_line "Lines"
    echo "==============================================================================="
  )"
	# Injection dans <system-out>
	awk -v summary="$COVERAGE_SUMMARY" '
		/<system-out>/ && !found { print; print "    <![CDATA[\n" summary "\n]]>"; found=1; next }
		/<!\[CDATA\[/ && found { next }
		/]]>/ && found { next }
		{ print }
	' "$ANGULAR_XML" > "$ANGULAR_XML.tmp" && mv "$ANGULAR_XML.tmp" "$ANGULAR_XML"
fi
echo "Tests terminés. Les rapports JUnit sont disponibles dans :"
echo "- Tous les rapports : test-results/"
ls -l test-results/
