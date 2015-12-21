//
//  maxminddb_unions.c
//  MMDB
//
//  Created by Lex on 12/17/15.
//  Copyright © 2015 LexTang.com. All rights reserved.
//

#include "maxminddb_unions.h"

const char *MMDB_get_entry_data_char(MMDB_entry_data_s *ptr) {
    return ptr->utf8_string;
}

uint32_t *MMDB_get_entry_data_uint32(MMDB_entry_data_s *ptr) {
    return &ptr->uint32;
}

bool MMDB_get_entry_data_bool(MMDB_entry_data_s *ptr) {
    return ptr->boolean;
}