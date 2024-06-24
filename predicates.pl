:-consult(data).

%1%
list_orders(CustomerName, L):-
customer(CustomerId, CustomerName),
get_orders(CustomerId,1,L),!.

get_orders(CustomerId,OrderId,[order(CustomerId, OrderId,Items)|T]):-
order(CustomerId, OrderId,Items),
NewOrderId is OrderId+1,
get_orders(CustomerId, NewOrderId,T).
get_orders(_,_,[]).



%2%
countOrdersOfCustomer(CustomerName,Count):-
list_orders(CustomerName,Orders),
count_orders(Orders,Count).

count_orders([],0).
count_orders([_|T],N):-
count_orders(T,NewN),
N is NewN+1.



%3%
getItemsInOrderById(CustomerName, OrderID, Items) :-
    customer(CustomerID, CustomerName),
    order(CustomerID, OrderID, Items),!.


%4
getNumOfItems(CustomerName, OrderId, Count):-
getItemsInOrderById(CustomerName, OrderId, Items),
count_items(Items,Count).

count_items([],0).
count_items([_|T],N):-
count_items(T,NewN),
N is NewN+1.



%5%
calcPriceOfOrder(CustomerName, OrderID, TotalPrice) :-
    order(CustomerID, OrderID, Items),
    calcTotalPrice(Items, OrderTotal),
    customer(CustomerID, CustomerName),
    TotalPrice is OrderTotal,!.

calcTotalPrice([], 0).
calcTotalPrice([Item|Rest], TotalPrice) :-
    item(Item, _, Price),
    calcTotalPrice(Rest, RemainingTotal),
    TotalPrice is RemainingTotal + Price.




%6%
isBoycott(ItemOrCompany) :-
    (   boycott_company(ItemOrCompany, _);item(ItemOrCompany, Company, _),boycott_company(Company, _)).



%7%
whyToBoycott(CompanyOrItem, Justification) :-
    (   boycott_company(CompanyOrItem, Justification)
    ;   item(CompanyOrItem, Company, _),
        boycott_company(Company, Justification)).


%8%
removeBoycottItemsFromAnOrder(Username, OrderID, NewList) :-
    customer(CustomerID, Username),
    order(CustomerID, OrderID, ItemList),
    removeBoycottItems(ItemList, NewList),!.

removeBoycottItems([], []).
removeBoycottItems([Item|Rest], NewList) :-
    (   boycottItem(Item)
    ->  removeBoycottItems(Rest, NewList)
    ;   NewList = [Item|NewRest],
        removeBoycottItems(Rest, NewRest)
    ).

boycottItem(Item) :-
    item(Item, Company, _),
    boycott_company(Company, _).


%9%
replaceBoycottItemsFromAnOrder(Username, OrderID, NewList) :-
    customer(CustomerID, Username),
    order(CustomerID, OrderID, ItemList),
    replaceBoycottItems(ItemList, NewList),!.

replaceBoycottItems([], []).
replaceBoycottItems([Item|Rest], [NewItem|NewRest]) :-
    (   boycottItem(Item),
        alternative(Item, AltItem)
    ->  NewItem = AltItem
    ;   NewItem = Item
    ),
    replaceBoycottItems(Rest, NewRest).


%10%
calcPriceAfterReplacingBoycottItemsFromAnOrder(Username, OrderID, NewList, TotalPrice) :-
    replaceBoycottItemsFromAnOrder(Username, OrderID, NewList),
    calculateTotalPrice(NewList, TotalPrice),!.

calculateTotalPrice([Item|Rest], TotalPrice) :-
    item(Item, _, Price),
    calculateTotalPrice(Rest, RestPrice),
    TotalPrice is RestPrice + Price.


calculateTotalPrice([], 0).
calculateTotalPrice([Item|Rest], TotalPrice) :-
    item(Item, _, Price),
    calculateTotalPrice(Rest, RestPrice),
    TotalPrice is RestPrice + Price.

%11%
getTheDifferenceInPriceBetweenItemAndAlternative(Item, Alternative, DiffPrice) :-
    item(Item, _, ItemPrice),
    alternative(Item, Alternative),
    item(Alternative, _, AltPrice),
    DiffPrice is ItemPrice - AltPrice.



%12%
:- dynamic(item/3).
:- dynamic(alternative/2).
:- dynamic(boycott_company/2).


add_item(Item, Brand, Price) :-
    \+ item(Item, _, _),
    assert(item(Item, Brand, Price)).
remove_item(Item, _, _) :-
    retract(item(Item, _, _)).
add_alternative(Item1, Item2) :-
    \+ alternative(Item1, Item2),
    assert(alternative(Item1, Item2)).
remove_alternative(Item1, Item2) :-
    retract(alternative(Item1, Item2)).
add_boycott_company(Company, Reason) :-
    \+ boycott_company(Company, _),
    assert(boycott_company(Company, Reason)).
remove_boycott_company(Company) :-
    retract(boycott_company(Company, _)).
