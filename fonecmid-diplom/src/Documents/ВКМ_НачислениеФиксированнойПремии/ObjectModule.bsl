#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
#Область ОбработчикиСобытий
Процедура ОбработкаПроведения(Отказ,Режим)
	
	// регистр ВКМ_ДополнительныеНачисления
	Движения.ВКМ_ДополнительныеНачисления.Записывать = Истина;
	Для Каждого ТекСтрокаСписокСотрудников из СписокСотрудников Цикл
		Движение = Движения.ВКМ_ДополнительныеНачисления.Добавить();
		Движение.Сторно = Ложь;
		Движение.ВидРасчета = ПланыВидовРасчета.ВКМ_ДополнительныеНачисления.ПремияФиксированная;
		Движение.ПериодРегистрации = Дата;
		Движение.Сотрудник = ТекСтрокаСписокСотрудников.Сотрудник;
		Движение.Результат = ТекСтрокаСписокСотрудников.СуммаПремии;
	КонецЦикла;

	// регистр ВКМ_Удержания
	Движения.ВКМ_Удержания.Записывать = Истина;
	Для Каждого ТекСтрокаСписокСотрудников из СписокСотрудников Цикл
		Движение = Движения.ВКМ_Удержания.Добавить();
		Движение.Сторно = Ложь;
		Движение.ВидРасчета = ПланыВидовРасчета.ВКМ_Удержания.НДФЛ;
		Движение.ПериодРегистрации = Дата;
		Движение.Сотрудник = ТекСтрокаСписокСотрудников.Сотрудник;
		Движение.Результат = ТекСтрокаСписокСотрудников.СуммаПремии*13/100;
	КонецЦикла;

КонецПроцедуры
#КонецОбласти
#КонецЕсли