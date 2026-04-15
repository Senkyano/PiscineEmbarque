/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   i2c_protocole.h                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: rihoy <rihoy@student.42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/15 16:21:12 by rihoy             #+#    #+#             */
/*   Updated: 2026/04/15 16:44:47 by rihoy            ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef I2C_PROTOCOLE_H
# define I2C__PROTOCOLE_H

# include <avr/io.h>
# include <util/delay.h>

typedef struct i2c_struct_s {
	volatile uint8_t	*port_sda;
	volatile uint8_t	*port_scl;
	volatile uint8_t	*ddr_sda;
	volatile uint8_t	*ddr_scl;
	volatile uint8_t	sda_pin;
	volatile uint8_t	scl_pin;
}	t_i2c_struct_t;

void	i2c_start(i2c_struct_t info_i2c);

#endif
