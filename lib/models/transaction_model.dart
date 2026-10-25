class TransactionModel {
 const TransactionModel({required this.description,required this.amount,required this.date,required this.isIncome,required this.balanceAfter,required this.category});
 final String description;
 final double amount;
 final DateTime date;
 final bool isIncome;
 final double balanceAfter;
 final String category;
 Map<String,Object?> toJson()=>{'description':description,'amount':amount,'date':date.toIso8601String(),'isIncome':isIncome,'balanceAfter':balanceAfter,'category':category};
 factory TransactionModel.fromJson(Map<String,Object?> j)=>TransactionModel(description:j['description'] as String? ?? '',amount:(j['amount'] as num?)?.toDouble()??0,date:DateTime.tryParse(j['date'] as String? ?? '')??DateTime.fromMillisecondsSinceEpoch(0),isIncome:j['isIncome'] as bool? ?? false,balanceAfter:(j['balanceAfter'] as num?)?.toDouble()??0,category:j['category'] as String? ?? 'General');
}
