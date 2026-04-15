/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: rihoy <rihoy@student.42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/15 13:17:49 by rihoy             #+#    #+#             */
/*   Updated: 2026/04/15 16:52:28 by rihoy            ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <avr/io.h>
#include <util/delay.h>
#include "i2c_protocole.h"

void	main_while(uint8_t *compteur)
{
	while (1)
	{
		if (!(PIND & (1 << PORTD2)))
		{
			_delay_ms(20);
			PORTB ^= (1 << PORTB0);
			while (!(PIND & (1 << PORTD2)))
				_delay_ms(20);
		}
		else if (!(PIND & (1 << PORTD4)))
		{
			_delay_ms(20);
			PORTB ^= (1 << PORTB4);
			while (!(PIND & (1 << PORTD4)))
				_delay_ms(20);
		}
	}
}

int	main(void)
{
	uint8_t			compteur;
	i2c_struct_t	info_i2c;

	DDRB = (1 << PORTB0) | (1 << PORTB4);
	DDRD &= ~(1 << PORTD2);
	DDRD &= ~(1 << PORTD4);
	info_i2c.port_sda = &PORTC;
	info_i2c.port_scl = &PORTC;
	info_i2c.ddr_sda = &DDRC;
	info_i2c.ddr_scl = &DDRC;
	info_i2c.sda_pin = PORTC4;
	info_i2c.scl_pin = PORTC5;
	compteur = 0;
	i2c_start(info_i2c);
	main_while(&compteur);
	return (0);
}
