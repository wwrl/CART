# CART
Analiza i Modelowanie Danych Transakcyjnych

Opis projektu

Ten projekt koncentruje się na analizie, czyszczeniu i modelowaniu danych transakcyjnych. Zawiera implementację modeli klasyfikacyjnych oraz regresyjnych do przewidywania statusu transakcji i ich kwot.

Wykorzystane technologie

Projekt został zrealizowany w języku R, przy użyciu następujących pakietów:

dplyr – przetwarzanie i transformacja danych

ggplot2 – wizualizacja

rpart, randomForest – modele klasyfikacyjne i regresyjne

caret, MLmetrics, pROC – ocena modeli

lubridate – manipulacja datami

Kroki analizy

1️⃣ Wczytanie i eksploracja danych

Dane są ładowane z pliku .RData, następnie przeprowadzana jest ich podstawowa eksploracja, w tym wizualizacja zmiennych:

Rozkład czasowy transakcji

Histogram kwot transakcji

Wykresy słupkowe dla zmiennych kategorycznych (issuer, recurringaction, status)

2️⃣ Czyszczenie i przetwarzanie danych

Konwersja wybranych zmiennych na format factor.

Tworzenie zmiennej day_of_week (dzień tygodnia transakcji).

Usunięcie niepotrzebnych kolumn (id, description, screenheight, itp.).

Filtrowanie danych, eliminacja wybranych wartości NA.

3️⃣ Budowa modeli klasyfikacyjnych

Stworzone zostały dwa modele klasyfikacyjne:

Drzewo decyzyjne (rpart) do przewidywania statusu transakcji (sukces vs porażka).

Drzewo decyzyjne z przycinaniem (prune) – optymalizacja modelu na podstawie kryterium cp.

Ocena modelu: Obliczenie macierzy błędów (confusion matrix), dokładności (accuracy) oraz F1-score.

4️⃣ Model regresyjny

Model regresyjny (rpart) do przewidywania wartości amount.

Przycinanie modelu (prune), optymalizacja parametrów.

Obliczenie błędów modelu (MSE, SSE).

5️⃣ Random Forest dla predykcji kwoty

Trening modelu randomForest do przewidywania wartości transakcji.

Ocena ważności zmiennych (varImpPlot).

Finalna predykcja i porównanie wyników.

Podsumowanie

Projekt przeprowadza pełen proces analizy transakcji – od wstępnej eksploracji, przez czyszczenie danych, po budowę modeli klasyfikacyjnych i regresyjnych. Wykorzystano zarówno klasyczne drzewa decyzyjne, jak i Random Forest do przewidywania kwot. Model klasyfikacyjny pozwala na analizę, które transakcje mogą zostać odrzucone przez bank, a model regresyjny pomaga estymować wartości transakcji.

Jak uruchomić?

Upewnij się, że masz zainstalowane wszystkie wymagane pakiety (install.packages(...)).

Wczytaj plik .RData z danymi.

Uruchom kod w RStudio.

Analizuj wyniki i wizualizacje!

Autor

Projekt opracowany w ramach analizy danych transakcyjnych. Jeśli masz pytania, zapraszam do kontaktu!
