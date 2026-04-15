/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   i2c_write.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: rihoy <rihoy@student.42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/15 18:09:03 by rihoy             #+#    #+#             */
/*   Updated: 2026/04/15 18:36:19 by rihoy            ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "i2c_protocole.h"

volatile uint8_t	i2c_write(t_i2c_struct_t info, uint8_t data)
{
	for (int i = 0; i < 8; i++) {
        // 1. Mettre SCL BAS
		*info.
        // 2. Sortir le bit (data & 0x80) sur SDA
        // 3. Mettre SCL HAUT
        // 4. Décaler data <<= 1
    }
    // 5. Gérer le 9ème bit (ACK)
    return (ack_status);
}

volatile uint8_t	i2c_send_bit(t_i2c_struct_t info, uint8_t data)
{
	
}