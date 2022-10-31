select
    'Hej ' + FirstName + '!' as Greeting,
    len(FirstName + LastName),
    len(FirstName + ' ' + LastName),
    len(FirstName) + len(LastName)
from Users

