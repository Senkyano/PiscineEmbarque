/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: rihoy <rihoy@student.42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/13 17:59:48 by rihoy             #+#    #+#             */
/*   Updated: 2026/04/14 22:28:28 by rihoy            ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <avr/io.h>
#include <util/delay.h>

int	main(void)
{
	DDRB = (1 << PORTB0);
	DDRD &= ~(1 << PORTD2);
	while (1)
	{
		if (!(PIND & (1 << PORTD2)))
		{
			_delay_ms(20);
			PORTB ^= (1 << PORTB0);
			while (!(PIND & (1 << PORTD2))) {}
			_delay_ms(20);
		}
	}
	return (0);
}
