
#!/bin/bash
# Lecture du fichier .env pour partager les chemins
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ENV_FILE="$SCRIPT_DIR/.env"
if [ -f "$ENV_FILE" ]; then
	set -o allexport
	source "$ENV_FILE"
	set +o allexport
fi


DEFAULT_ANGULAR_DIR=Frontend
DEFAULT_JAVA_DIR=Backend

find_angular_dir() {
	local candidate
	for candidate in "${ANGULAR_DIR:-}" "$DEFAULT_ANGULAR_DIR" . */; do
		[ -n "$candidate" ] || continue
		candidate=${candidate%/}
		[ -d "$candidate" ] || continue
		if [ -f "$candidate/angular.json" ]; then
			printf '%s\n' "$candidate"
			return 0
		fi
		if [ -f "$candidate/package.json" ] && grep -q '"@angular/core"' "$candidate/package.json" 2>/dev/null; then
			printf '%s\n' "$candidate"
			return 0
		fi
	done
	return 1
}

find_java_dir() {
	local candidate
	for candidate in "${JAVA_DIR:-}" "$DEFAULT_JAVA_DIR" . */; do
		[ -n "$candidate" ] || continue
		candidate=${candidate%/}
		[ -d "$candidate" ] || continue
		if [ -f "$candidate/gradlew" ] || [ -f "$candidate/build.gradle" ] || [ -f "$candidate/pom.xml" ]; then
			printf '%s\n' "$candidate"
			return 0
		fi
	done
	return 1
}

ANGULAR_DIR=$(find_angular_dir) || {
	echo "Projet Angular introuvable."
	exit 1
}

JAVA_DIR=$(find_java_dir) || {
	echo "Projet Java introuvable."
	exit 1
}


# Nettoyage des anciens rapports
rm -rf test-results/
rm -rf "$ANGULAR_DIR/coverage/"
rm -rf "$ANGULAR_DIR/reports/"
# Script pour lancer les tests backend (Java) et frontend (Angular)
# et gÃ©nÃ©rer des rapports JUnit XML pour GitHub Actions

set -e

# Backend Java
cd "$JAVA_DIR"

echo "[Backend] Lancement des tests Java..."
chmod +x ./gradlew
./gradlew clean test --no-daemon --console=plain || echo "[Backend] Les tests Java ont Ã©chouÃ©, on continue."
# Les rapports JUnit sont gÃ©nÃ©rÃ©s dans build/test-results/test
cd ..

# Frontend Angular
cd "$ANGULAR_DIR"

echo "[Frontend] Lancement des tests Angular..."
npm install
npm run test -- --watch=false --browsers=ChromeHeadless --reporters=junit,progress --code-coverage
# Les rapports JUnit sont gÃ©nÃ©rÃ©s dans ./test-results/junit/
cd ..

# CrÃ©ation du dossier test-results/ Ã  la racine si besoin
mkdir -p test-results

# Copie des rapports Java
if [ -d "$JAVA_DIR/build/test-results/test" ]; then
    cp "$JAVA_DIR/build/test-results/test"/*.xml test-results/ 2>/dev/null || true
fi

# Copie des rapports Angular (test-results/junit ou reports)
if [ -d "$ANGULAR_DIR/test-results/junit" ]; then
    cp "$ANGULAR_DIR/test-results/junit"/*.xml test-results/ 2>/dev/null || true
fi
if [ -d "$ANGULAR_DIR/reports" ]; then
    cp "$ANGULAR_DIR/reports"/*.xml test-results/ 2>/dev/null || true
fi


echo "\nRÃ©sumÃ© de la couverture de code (Angular) :"
COVERAGE_HTML="$ANGULAR_DIR/coverage/olympic-games-starter/index.html"
if [ -f "$COVERAGE_HTML" ]; then
	grep -A2 'Statements' "$COVERAGE_HTML" | head -n 3 | sed -E 's/<[^>]+>//g' | paste -sd ' ' - | sed 's/  */ /g' | awk '{print "Statements   : "$2" ( "$3" )"}'
	grep -A2 'Branches' "$COVERAGE_HTML" | head -n 3 | sed -E 's/<[^>]+>//g' | paste -sd ' ' - | sed 's/  */ /g' | awk '{print "Branches     : "$2" ( "$3" )"}'
	grep -A2 'Functions' "$COVERAGE_HTML" | head -n 3 | sed -E 's/<[^>]+>//g' | paste -sd ' ' - | sed 's/  */ /g' | awk '{print "Functions    : "$2" ( "$3" )"}'
	grep -A2 'Lines' "$COVERAGE_HTML" | head -n 3 | sed -E 's/<[^>]+>//g' | paste -sd ' ' - | sed 's/  */ /g' | awk '{print "Lines        : "$2" ( "$3" )"}'
else
    echo "Pas de rapport de couverture trouvÃ©."
fi

# RÃ©sumÃ© de la couverture backend Java (Jacoco)
echo "\nRÃ©sumÃ© de la couverture de code (Backend Java) :"
JACOCO_HTML="$JAVA_DIR/build/reports/jacoco/test/html/index.html"
if [ -f "$JACOCO_HTML" ]; then
	grep -A2 'Covered Instructions' "$JACOCO_HTML" | head -n 3 | sed -E 's/<[^>]+>//g' | paste -sd ' ' - | sed 's/  */ /g' | awk '{print "Instructions : "$2" ( "$3" )"}'
	grep -A2 'Covered Branches' "$JACOCO_HTML" | head -n 3 | sed -E 's/<[^>]+>//g' | paste -sd ' ' - | sed 's/  */ /g' | awk '{print "Branches     : "$2" ( "$3" )"}'
	grep -A2 'Covered Methods' "$JACOCO_HTML" | head -n 3 | sed -E 's/<[^>]+>//g' | paste -sd ' ' - | sed 's/  */ /g' | awk '{print "Methods      : "$2" ( "$3" )"}'
	grep -A2 'Covered Lines' "$JACOCO_HTML" | head -n 3 | sed -E 's/<[^>]+>//g' | paste -sd ' ' - | sed 's/  */ /g' | awk '{print "Lines        : "$2" ( "$3" )"}'
	# GÃ©nÃ©ration d'un fichier coverage-summary-backend.xml pour rÃ©cupÃ©ration CI
	BACKEND_COVERAGE_SUMMARY="$(
		echo "=============================== Backend Coverage summary ==============================="
		grep -A2 'Covered Instructions' "$JACOCO_HTML" | head -n 3 | sed -E 's/<[^>]+>//g' | paste -sd ' ' - | sed 's/  */ /g' | awk '{print "Instructions : "$2" ( "$3" )"}'
		grep -A2 'Covered Branches' "$JACOCO_HTML" | head -n 3 | sed -E 's/<[^>]+>//g' | paste -sd ' ' - | sed 's/  */ /g' | awk '{print "Branches     : "$2" ( "$3" )"}'
		grep -A2 'Covered Methods' "$JACOCO_HTML" | head -n 3 | sed -E 's/<[^>]+>//g' | paste -sd ' ' - | sed 's/  */ /g' | awk '{print "Methods      : "$2" ( "$3" )"}'
		grep -A2 'Covered Lines' "$JACOCO_HTML" | head -n 3 | sed -E 's/<[^>]+>//g' | paste -sd ' ' - | sed 's/  */ /g' | awk '{print "Lines        : "$2" ( "$3" )"}'
		echo "========================================================================================="
	)"
	echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > test-results/coverage-summary-backend.xml
	echo "<coverage-summary-backend>" >> test-results/coverage-summary-backend.xml
	echo "<![CDATA[" >> test-results/coverage-summary-backend.xml
	echo "$BACKEND_COVERAGE_SUMMARY" >> test-results/coverage-summary-backend.xml
	echo "]]>" >> test-results/coverage-summary-backend.xml
	echo "</coverage-summary-backend>" >> test-results/coverage-summary-backend.xml
else
	echo "Pas de rapport de couverture Jacoco trouvÃ©."
fi
ANGULAR_XML=$(ls test-results/TESTS-Chrome_Headless_*.xml 2>/dev/null | head -n1)
COVERAGE_HTML="$ANGULAR_DIR/coverage/olympic-games-starter/index.html"
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
	REPORT_XML="test-results/Report-summary.xml"
	echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > "$REPORT_XML"
	echo "<report-summary>" >> "$REPORT_XML"
	echo "  <angular-coverage><![CDATA[" >> "$REPORT_XML"
	echo "$COVERAGE_SUMMARY" >> "$REPORT_XML"
	echo "]]></angular-coverage>" >> "$REPORT_XML"

	# Ajout du rÃ©sumÃ© backend Jacoco si dispo
	if [ -f "test-results/coverage-summary-backend.xml" ]; then
		awk '/<coverage-summary-backend>/,/<\/coverage-summary-backend>/' test-results/coverage-summary-backend.xml >> "$REPORT_XML"
	fi

	# GÃ©nÃ©ration du tableau des rÃ©sultats backend
	echo "  <backend-test-summary><![CDATA[" >> "$REPORT_XML"
	echo -e "Class\tTests\tFailures\tIgnored\tDuration\tSuccess rate" >> "$REPORT_XML"
	for xml in test-results/TEST-fr.oc.devops.backend.services.*.xml; do
		if [ -f "$xml" ]; then
			class=$(awk -F '"' '/<testsuite/{print $2}' "$xml")
			tests=$(awk -F '"' '/<testsuite/{for(i=1;i<=NF;i++) if($i=="tests") print $(i+2)}' "$xml")
			failures=$(awk -F '"' '/<testsuite/{for(i=1;i<=NF;i++) if($i=="failures") print $(i+2)}' "$xml")
			errors=$(awk -F '"' '/<testsuite/{for(i=1;i<=NF;i++) if($i=="errors") print $(i+2)}' "$xml")
			time=$(awk -F '"' '/<testsuite/{for(i=1;i<=NF;i++) if($i=="time") print $(i+2)}' "$xml")
			ignored=0
			success_rate=$(( (failures + errors == 0) ? 100 : 0 ))
			printf "%s\t%s\t%s\t%s\t%.3fs\t%d%%\n" "$class" "$tests" "$failures" "$ignored" "$time" "$success_rate" >> "$REPORT_XML"
		fi
	done
	echo "]]></backend-test-summary>" >> "$REPORT_XML"
	echo "</report-summary>" >> "$REPORT_XML"
fi
echo "Tests terminÃ©s. Les rapports JUnit sont disponibles dans :"
echo "- Tous les rapports : test-results/"
ls -l test-results/
