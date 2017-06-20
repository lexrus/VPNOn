//
//  maxminddb_unions.h
//  MMDB
//
//  Created by Lex on 12/17/15.
//  Copyright © 2017 lexrus.com. All rights reserved.
//

#ifndef maxminddb_unions_h
#define maxminddb_unions_h

#include <stdio.h>
#include "maxminddb.h"

const char *MMDB_get_entry_data_char(MMDB_entry_data_s *ptr);
uint32_t *MMDB_get_entry_data_uint32(MMDB_entry_data_s *ptr);
bool MMDB_get_entry_data_bool(MMDB_entry_data_s *ptr);


#endif /* maxminddb_unions_h */
