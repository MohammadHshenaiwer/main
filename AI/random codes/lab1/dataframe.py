import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv("retail_store_inventory.csv")
# print(df.tail())
# print(df.dtypes)
# print(df.describe())
# print(df.info())
# print(df.shape)

data= df.copy()
#print(data)
#print(data["Weather Condition"])
#print(data["Weather Condition"].unique())
#print(data["Weather Condition"].value_counts())
#print(data.isnull().sum())


# value = data["Demand Forecast"].mean()
# data.fillna({"Demand Forecast":value}, inplace=True)

# print(data.isnull().sum())
# data['Category'] = data['Category'].fillna(data['Category'].mode()[0])

#1
value= data['Units Sold'].mean()
data.fillna({"Units Sold":value}, inplace=True)
# print(data.isnull().sum())

#2
value2 = (data[data['Category'] == 'Toys']['Price'].mean())

#3


data['Total Revenue'] = data['Units Sold'] * data['Price']



#4

min=data['Units Ordered'].min()
max=data['Units Ordered'].max()
print(min,max)
total=data['Units Ordered'].sum()
print(total)

#5
avg_units_by_category = data.groupby('Category')['Units Sold'].mean()
avg_units_by_category.plot(kind='bar', title='avrege unit sold by category')
plt.xlabel('Category')
plt.ylabel('Average Units Sold')
plt.show()


#6

print("Total duplicate rows:", data.duplicated().sum())
data.drop_duplicates(inplace=True)
print("Duplicates removed! New shape:", data.shape)


# #7
print(data[(data['Units Sold'] < 200) & (data['Demand Forecast'] > 250)])

# #8
 print(data.groupby('Seasonality')['Price'].mean())

# #9

print(data[data['Inventory Level'] == 200])

#10
print(data.groupby('Category')['Units Ordered'].std())

#11 - Relationship between Price and Total Revenue
data.plot(kind='scatter', x='Price', y='Total Revenue', title='Price vs Total Revenue')
plt.show()