Uruchomienie:

1) Załadowanie kontenera
Poprzez konsolę należy wejść do folderu, w którym umieszczono wszystkie pliki znajdujące się w BD_projekt.rar, a następnie wkleić poniższe komendy:

docker build -t bd_image .

docker run -d -p 3308:3306 --name bd_projekt bd_image

Pierwsza buduje obraz z pliku Dockerfile, druga tworzy kontener ze zbudowanego obrazu.

2) Utworzenie bazy 

W pliku database.sql znajdują się wszystkie polecenia, które są potrzebne, żeby baza była spójna.
Jest on uruchamiany wraz z budowaniem obrazu.

Plik database_2.sql zawiera procedurę wyświetlającą dane klienta, kwotę transakcji, typ karty i predykcję.

3) Model w Jupyter Notebook (Python)

Plik BD_projekt.ipynb zawiera analizę zbioru. 
Po kolei:
	3.1) Załadowanie bibliotek, zbioru i funkcji, których użyto w dalszej części.
	3.2) Podział danych na zbiory testowe i treningowe. Modele uczymy na zbiorze treningowym.* 
	     Zbiór załadowany do bazy danych, jest zbiorem testowym z powyższego podziału.
	3.3) Histogram, macierz korelacji, wyświetlone poglądowo.
	3.4) Regresja logistyczna
		3.4.1) Sprawdzamy próg klasyfikacji znajdujący się nabliżej punktu (0,1) krzywej ROC.
		3.4.2) Sprawdzamy próg klasyfikacji 0.5 (klasyczny).
		3.4.3) Sprawdzamy próg klasyfikacji 0.85, wygenerowany na podstawie optymalizacji ilości popełnianych błędów na zbiorze testowym.
		3.4.4) Sprawdzamy próg klasyfikacji 0.86. Uznajemy za najlepszy dla tego modelu.
	3.5) Drzewo decyzyjne.
	3.6) Random Forest, uznany za najlepszy. Na jego podstawie wybieramy finalny model.
	3.7) Połączenie z dockerem, funkcja dodająca wiersze do bazy.

Po uruchomieniu funkcji "insert_data" w pliku BD_projekt.ipynb, możemy za pomocą database_2.sql i zawartej w niej procedury,
analizować "na żywo" aktualizację bazy danych.

* Podział na zbiory wymaga załadowania pliku creditcard.csv
