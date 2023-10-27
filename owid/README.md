A set of helpers for interacting with datasources we maintain at Our World In Data. Some are accessible by the public, some only by internal team members.

You can use this either by just importing this whole directory as a module:
```nushell
use /path/to/owid
```

or by importing it as an overly. I prefer to keep the owid prefix so I do
```nushell
overlay use --prefix /path/to/owid
```