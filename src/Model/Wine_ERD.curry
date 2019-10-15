-- ERD for wine management

import Database.ERD

wineERD :: ERD
wineERD =
 ERD "Wine" 
  [Entity "Category"
    [Attribute "Name" (StringDom Nothing) NoKey False],
   Entity "Wine" 
    [Attribute "Name"    (StringDom Nothing) NoKey False,
     Attribute "Region"  (StringDom Nothing) NoKey False, 
     Attribute "Year"    (IntDom    Nothing) NoKey False, 
     Attribute "Price"   (StringDom Nothing) NoKey False,
     Attribute "Bottles" (IntDom    Nothing) NoKey False
    ]
  ]
  [Relationship "WineCategory"
    [REnd "Category" "inCategory" (Exactly 1),
     REnd "Wine"     "withWine"   (Between 0 Infinite)]
  ]
